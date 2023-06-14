//
//  ViewController.swift
//  ARKit Game
//
//  Created by Naman Alagh on 09/06/23.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    var asteroids: [Entity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let anchor = AnchorEntity(.plane(.horizontal, classification: .floor, minimumBounds: [0.2,0.2]))
        arView.scene.addAnchor(anchor)
        
        var cards: [Entity] = []
        
        for _ in 1...4 {
            let box = MeshResource.generateBox(width: 0.04, height: 0.002, depth: 0.04)
            let metalMaterial = SimpleMaterial(color: .gray, isMetallic: true)
            let model = ModelEntity(mesh: box, materials: [metalMaterial])
            
            model.generateCollisionShapes(recursive: true)
            
            cards.append(model)
        }
        
        for (i,card) in cards.enumerated(){
            let x = Float(i % 2)
            let z = Float(i / 2)
            
            card.position = [x*0.1, 0, z*0.1]
            //anchor.addChild(card)
        }
        
        
        
        let asteroid = MeshResource.generateSphere(radius: 0.05)
        let asteroidMat = SimpleMaterial(color: .black, roughness: 0.8, isMetallic: false)
        
        for _ in 1...3 {
            let model = ModelEntity(mesh: asteroid, materials: [asteroidMat])
            
            model.generateCollisionShapes(recursive: true)
            
            asteroids.append(model)
        }
        
        for (i,asteroid) in asteroids.enumerated(){
            let x = Float(i % 3)
            //let y = Float(i / 3)
            
            asteroid.position = [x*0.2, 1, -5]
            anchor.addChild(asteroid)
            
            
        }
        
        
        
//        // Load the "Box" scene from the "Experience" Reality File
//        let boxAnchor = try! Experience.loadBox()
//
//        // Add the box anchor to the scene
//        arView.scene.anchors.append(boxAnchor)
    }
    
    
    
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        //let tapLocation = sender.location(in: arView)
//        if let card = arView.entity(at: tapLocation){
//             if card.transform.rotation.angle == .pi{
//                var flipDownTransform = card.transform
//                flipDownTransform.rotation = simd_quatf(angle: 0, axis: [1,0,0])
//                card.move(to: flipDownTransform, relativeTo: card.parent, duration: 0.25, timingFunction: .easeInOut)
//            } else{
//                var flipUpTransform = card.transform
//                flipUpTransform.rotation = simd_quatf(angle: .pi, axis: [1,0,0])
//                card.move(to: flipUpTransform, relativeTo: card.parent, duration: 0.25, timingFunction: .easeInOut)
//
//            }
//        }
        for (_,asteroid) in asteroids.enumerated(){
            var moveTo = asteroid.transform
            //var moveTo = arView.cameraTransform
            moveTo.translation = vector3(asteroid.transform.translation.x, 1, arView.cameraTransform.translation.z + 3)
            
            asteroid.move(to: moveTo, relativeTo: asteroid.parent, duration: 10)
        }
    }
}


