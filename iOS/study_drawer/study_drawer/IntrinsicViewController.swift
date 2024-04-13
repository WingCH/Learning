//
//  IntrinsicViewController.swift
//  study_drawer
//
//  Created by Wing on 13/4/2024.
//

import FloatingPanel
import Foundation
import TinyConstraints
import UIKit

class IntrinsicViewController: UIViewController {
    lazy var label = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(label)

        
        label.edgesToSuperview(excluding: .bottom, insets: .top(24))
        label.bottomToSuperview(relation: .equalOrLess)
        label.numberOfLines = 0

        // long text
        label.text = """
        Dolorum odio pariatur tempora laborum neque ab harum libero et saepe est dolores voluptate. Velit nam ut atque rem eos itaque libero aut deserunt. Aspernatur maxime nihil eos rerum corporis est quia officiis. Laboriosam vel eum commodi autem quam saepe. Aspernatur ea fugiat molestiae aut aut dolores quasi. Ipsum voluptas corporis deleniti expedita et ipsa inventore et et id ut a doloribus. Perferendis vel explicabo et omnis voluptas distinctio esse eaque repudiandae et molestiae rerum cumque aut. Voluptatibus voluptatum magni commodi tempore quia non.
        """
    }
}

// extension IntrinsicViewController: FloatingPanelControllerDelegate {
//    func floatingPanel(_ fpc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> any FloatingPanelLayout {
//        return IntrinsicPanelLayout()
//    }
//
//    func floatingPanel(_ fpc: FloatingPanelController, shouldRemoveAt location: CGPoint, with velocity: CGVector) -> Bool {
//        print("shouldRemoveAt location: \(location)")
//        return false
//    }
// }

// Reference from: https://github.com/scenee/FloatingPanel/blob/8f2be39bf49b4d5e22bbf7bdde69d5b76d0ecd2a/Examples/Samples/Sources/PanelLayouts.swift#L33
class IntrinsicPanelLayout: FloatingPanelBottomLayout {
    // Sets the initial state of the panel to fully expanded
    override var initialState: FloatingPanelState { .full }
    override var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            // Set the full height of the view controller as the height for the FloatingPanel
            .full: FloatingPanelIntrinsicLayoutAnchor(fractionalOffset: 0.0, referenceGuide: .safeArea)
        ]
    }
}

class IntrinsicPanelBehavior: FloatingPanelBehavior {
    // Lower the velocity threshold to make it easier for users to dismiss the FloatingPanel by dragging down
    var removalInteractionVelocityThreshold: CGFloat = 2
}
