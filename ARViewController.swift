//
//  ARViewController.swift
//  ARKit Game
//
//  Created by Naman Alagh on 12/06/23.
//

import UIKit
import SceneKit
import ARKit

class ARViewController: UIViewController,ARSCNViewDelegate,ARSessionDelegate,SCNPhysicsContactDelegate {

    @IBOutlet weak var arView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    var modelNode: SCNNode!
    var gameNode = SCNNode()
    var gamePos = SCNVector3(0.0, 0.0, 0.0)
    var gameHasStarted = false
    var moveIndex = 2
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerGestureRecognizers()
        
        arView.scene.physicsWorld.contactDelegate = self
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            if(self.gameHasStarted){
                self.initializeObstacles()
            }
        })
        
        self.arView.session.run(configuration)
        self.arView.autoenablesDefaultLighting = true
        
        let currentScene = SCNScene(named: "rocket.dae")
        guard let currentModel = currentScene?.rootNode.childNode(withName: "Body", recursively: true) else {
            fatalError("No model found.")
        }
        modelNode = currentModel
        modelNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: SCNBox(width: 1*0.2, height: 1*0.2, length: 1*0.2, chamferRadius: 0)))
        modelNode.physicsBody?.categoryBitMask = CollisionCategory.rocketCategory.rawValue
        modelNode.physicsBody?.collisionBitMask = CollisionCategory.asteroidCategory.rawValue
        
        //-1148
        currentModel.position = SCNVector3(x: 0, y: 0, z: -5)
        self.arView.scene.rootNode.addChildNode(gameNode)
        //self.arView.scene = currentScene!
        gameNode.position = SCNVector3(x: 0, y: -2, z: 0)
        gameNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: ConvertDegreesToRadians(angle: 25))
        gameNode.addChildNode(modelNode)
        let spin = SCNAction.rotate(by: .pi, around: modelNode.position, duration: 3)
        let spinForever = SCNAction.repeatForever(spin)
        
        modelNode.runAction(spinForever)
    }
    
    func ConvertDegreesToRadians(angle: Float) -> Float{
        return Float(3.14 / 180) * angle
    }
    
    private func registerGestureRecognizers(){
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
            swipeRight.direction = .right
            self.view.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
            swipeLeft.direction = .left
            self.view.addGestureRecognizer(swipeLeft)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.arView.addGestureRecognizer(tapGesture)
        
    }


    @objc func swiped(_ gesture: UISwipeGestureRecognizer){
        
        let dir = gesture.direction
        //var rotAngle = 1
        
        var moveTo = SCNAction.moveBy(x: 0, y: 0, z: 0, duration: 0)
        
        if dir == .left && moveIndex>1{
            moveIndex-=1
            //rotAngle = -1
            moveTo = SCNAction.moveBy(x: -0.5, y: 0, z: 0, duration: 0.5)
            
        } else if dir == .right && moveIndex<3{
            moveIndex+=1
            //rotAngle = 1
            moveTo = SCNAction.moveBy(x: 0.5, y: 0, z: 0, duration: 0.5)
        }
        
//        modelNode.position.x = Float(moveIndex)*0.5
        //let spin = SCNAction.rotate(by: .pi * CGFloat(rotAngle), around: modelNode.position, duration: 0.5)
        //print(moveIndex)
        modelNode.runAction(moveTo)
        //modelNode.runAction(spin)

    }

    func initializeObstacles(){
        let num = Int.random(in: -1...1)
        let asteroid = generateAsteroid(index: num)
        gameNode.addChildNode(asteroid)
    }
    
    func generateAsteroid(index: Int) -> SCNNode{
        let node = SCNNode()
        
        node.geometry = SCNSphere(radius: 0.2)
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        
        let x = Float(index % 3)
        
        node.position = SCNVector3(x*0.5, 0, -20)
//        var moveTo = SCNAction.moveBy(x: 0, y: 0, z: 5, duration: 4)
        
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: SCNSphere(radius: 0.2)))
        node.physicsBody?.categoryBitMask = CollisionCategory.asteroidCategory.rawValue
        node.physicsBody?.collisionBitMask = CollisionCategory.rocketCategory.rawValue
        
        let moveTo = SCNAction.move(to: SCNVector3(x: node.position.x, y: 0, z: 5), duration: 10)
        
        
        
        node.runAction(moveTo)
        return node
    }
    
    @objc func tapped(_ gesture: UITapGestureRecognizer) {
        gameHasStarted = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
            
             //print("** Collision!! " + contact.nodeA.name! + " hit " + contact.nodeB.name!)
        print("Collision")
        
            if contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.rocketCategory.rawValue
                || contact.nodeB.physicsBody?.categoryBitMask == CollisionCategory.rocketCategory.rawValue {

                
                gameHasStarted = false
            }
        }

}

struct CollisionCategory: OptionSet {
   let rawValue: Int
   static let asteroidCategory  = CollisionCategory(rawValue: 2)
//   static let asteroidCategory  = CollisionCategory(rawValue: 1 << 0)
   static let rocketCategory = CollisionCategory(rawValue: 8)
//   static let rocketCategory = CollisionCategory(rawValue: 1 << 1)
}


