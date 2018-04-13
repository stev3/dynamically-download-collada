//
//  ViewController.swift
//  loading-files
//
//  Created by Steven Jenkins on 4/13/18.
//  Copyright © 2018 Steven Jenkins. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SSZipArchive
import Alamofire

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true
        
        self.setupWorldTracking()
        
        downloadZip(modelURLString: "https://s3.amazonaws.com/xmodels/outfile.dae.zip")

    }
    
    func downloadZip(modelURLString: String) {
        guard let url = URL(string: modelURLString) else { return }        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        Alamofire.download(
            url,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: nil,
            to: destination).downloadProgress(closure: { (progress) in
                print(progress)
            }).response(completionHandler: { (DefaultDownloadResponse) in
                
                guard let zipPath = DefaultDownloadResponse.destinationURL?.path else { return }
                var documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let success: Bool = SSZipArchive.unzipFile(atPath: zipPath,
                                                           toDestination: documentsDirectory,
                                                           preserveAttributes: true,
                                                           overwrite: true,
                                                           nestedZipLevel: 1,
                                                           password: nil,
                                                           error: nil,
                                                           delegate: nil,
                                                           progressHandler: nil,
                                                           completionHandler: nil)
                if success != false {
                    print("Successly unzipped")
                    self.startScene()
                } else {
                    print("Failed to unzip")
                    return
                }
            })
    }
    
    func startScene() {
        var documentsDirectoryURL: URL? = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        documentsDirectoryURL = documentsDirectoryURL?.appendingPathComponent("outfile.dae")
        let node = SCNReferenceNode(url: documentsDirectoryURL!)
        node?.load()
        self.sceneView.scene.rootNode.addChildNode(node!)
    }
    
    private func setupWorldTracking() {
        if ARWorldTrackingConfiguration.isSupported {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            configuration.isLightEstimationEnabled = true
            self.sceneView.session.run(configuration, options: [])
        }
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
