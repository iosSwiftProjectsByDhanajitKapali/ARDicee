//
//  ViewController.swift
//  ARDicee
//
//  Created by unthinkable-mac-0025 on 13/02/22.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    var diceArray = [SCNNode]()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        //let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
//        let sphere = SCNSphere(radius: 0.1)
//        let material = SCNMaterial()
//        material.diffuse.contents = UIImage(named: "art.scnassets/8k_earth_daymap.jpeg")
//        sphere.materials = [material]
//        let node = SCNNode()
//        node.position = SCNVector3(0, 0, -0.2)
//        node.geometry = sphere
//        sceneView.scene.rootNode.addChildNode(node)
        sceneView.autoenablesDefaultLighting = true
        
        // Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true){
            diceNode.position = SCNVector3(0, 0, -0.1)
            // Set the scene to the view
            sceneView.scene.rootNode.addChildNode(diceNode)
        }
            
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let touchLocation = touch.location(in: sceneView)
            
            //convert this 2D location of the touch to 3D coordinate for the ARScene
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            if let hitResult = results.first{
                print("Touched the plane")
                // Create a new scene
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true){
                    diceNode.position = SCNVector3(
                        hitResult.worldTransform.columns.3.x,
                        hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                        hitResult.worldTransform.columns.3.z
                    )
                    
                    diceArray.append(diceNode)
                    
                    // Set the scene to the view
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    
                    rollDice(dice: diceNode)
                }
                
            }else{
                print("Touched outside the plane")
            }
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAllDices()
    }
}

private extension ViewController{
    func rollAllDices(){
        if !diceArray.isEmpty{
            for dice in diceArray{
                rollDice(dice : dice)
            }
        }
    }
    
    func rollDice(dice : SCNNode){
        //generate some random angles(multiple of 90-deg) to rotate the dice
        let randomX = (Float(arc4random_uniform(4)) + 1) * (Float.pi/2)
        let randomZ = (Float(arc4random_uniform(4)) + 1) * (Float.pi/2)
        
        dice.runAction(SCNAction.rotateTo(
            x: CGFloat(randomX * 3),
            y: 0,
            z: CGFloat(randomZ * 3),
            duration: 0.5
        ))
    }
}

extension ViewController : ARSCNViewDelegate{
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor{ //check if its a 2D plane anchor
            let planeAnchor = anchor as! ARPlaneAnchor
            //create a plane
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            //create a node
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
            //Rotate the plane created above
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            //create the material for the plane
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            node.addChildNode(planeNode)
            
        }else{
            return
        }
    }
}
