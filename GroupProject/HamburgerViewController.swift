import UIKit

class HamburgerViewController: UIViewController {
    
    static let sharedInstance = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HamburgerMenu") as! HamburgerViewController
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var leftMargainConstraint: NSLayoutConstraint!
    var originalLeftMargin: CGFloat!
    var openPositionLeftMarginConstant: CGFloat!
    var closedPositionLeftMarginConstant: CGFloat!
    
    var menuViewController: MenuViewController!{
        didSet{
            view.layoutIfNeeded()
            menuView.addSubview(menuViewController.view)
        }
    }
    
    var contentViewController: UIViewController! {
        didSet(oldContentViewController){
            view.layoutIfNeeded()
            
            if oldContentViewController != nil {
                oldContentViewController.willMove(toParentViewController: nil)
                oldContentViewController.view.removeFromSuperview()
                oldContentViewController.didMove(toParentViewController: nil)
            }
            
            contentViewController.willMove(toParentViewController: self)
            contentView.addSubview(contentViewController.view)
            contentViewController.didMove(toParentViewController: self)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.leftMargainConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup open and closed position constants
        openPositionLeftMarginConstant = self.view.frame.size.width - 190
        closedPositionLeftMarginConstant = 0
    }
    
    override func viewDidLayoutSubviews() {
        //User.sharedInstance.updateUser()
        if User.sharedInstance.nativeCountry == nil {
            
            let storyboard = UIStoryboard(name: "ChooseLocation", bundle: nil)
            let viewController = storyboard.instantiateInitialViewController()
            present(viewController!, animated: true, completion: nil)
        }
    }
    
    func moveMenu() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [],
                       animations: {
                        if self.leftMargainConstraint.constant == 0 {
                            self.leftMargainConstraint.constant = self.openPositionLeftMarginConstant
                            self.contentView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                            self.updateRotation(200)
                            
                        } else {
                            self.leftMargainConstraint.constant = self.closedPositionLeftMarginConstant
                            self.contentView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        }
                        self.view.layoutIfNeeded()
        })
    }
    
    func updateRotation(_ offset: CGFloat) {
        var transform = CATransform3DIdentity
        let perspective = 250
        transform.m34 = 1.0 / CGFloat(perspective)
        
        let rotation = offset * 20.0 / 320.0
        
        transform = CATransform3DRotate(transform, rotation * CGFloat(M_PI / 180), 0, 1, 0)
        //contentView.layer.transform = transform
        let shrink = CATransform3DScale(transform, 0.80, 0.80, 1)
        CATransform3DConcat(transform, shrink)
        contentView.layer.transform = shrink
        contentView.layer.zPosition = 100

    }
    
    @IBAction func onPanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)

        // Restricts pan gesture, 
        //      towards right when hamburger menu is in open position
        //      towards left when hamburger menu is in closed position
        if ((leftMargainConstraint.constant == closedPositionLeftMarginConstant && velocity.x < 0) ||
            leftMargainConstraint.constant == openPositionLeftMarginConstant && velocity.x > 0) {
            return
        }

        if sender.state == UIGestureRecognizerState.began {
            originalLeftMargin = leftMargainConstraint.constant
        } else if sender.state == UIGestureRecognizerState.changed {
            leftMargainConstraint.constant = originalLeftMargin + translation.x
            
        } else if sender.state == UIGestureRecognizerState.ended{

            UIView.animate(withDuration: 0.3, animations: { 
                if velocity.x > 0 {
                    self.contentView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

                    self.leftMargainConstraint.constant = self.openPositionLeftMarginConstant

                } else {
                    self.contentView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)

                    self.leftMargainConstraint.constant = self.closedPositionLeftMarginConstant
                }
                self.view.layoutIfNeeded()

            }, completion: { (_) in
                // Confidently assumes its Dashbaseviewcontroller!
                let viewController = (self.contentViewController as! UINavigationController).viewControllers[0] as! DashBaseViewController
                viewController.HamburgerButton.showsMenu = !viewController.HamburgerButton.showsMenu
            })
        }
    }
}
