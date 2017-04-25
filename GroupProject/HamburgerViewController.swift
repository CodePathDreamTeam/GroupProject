import UIKit

class HamburgerViewController: UIViewController {
    
    static let sharedInstance = UIStoryboard(name: "Hamburger", bundle: nil).instantiateViewController(withIdentifier: "HamburgerMenu") as! HamburgerViewController

    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var leftMargainConstraint: NSLayoutConstraint!
    var originalLeftMargin: CGFloat!
    
    var menuViewController: UIViewController!{
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
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func moveMenu() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [],
                       animations: {
                        if self.leftMargainConstraint.constant == 0 {
                            self.leftMargainConstraint.constant = self.view.frame.size.width - 60
                        } else {
                            self.leftMargainConstraint.constant = 0
                        }
                        self.view.layoutIfNeeded()
        })
        
    }
    
    @IBAction func onPanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        if sender.state == UIGestureRecognizerState.began {
            originalLeftMargin = leftMargainConstraint.constant
        } else if sender.state == UIGestureRecognizerState.changed {
            leftMargainConstraint.constant = originalLeftMargin + translation.x
            
        } else if sender.state == UIGestureRecognizerState.ended{
            UIView.animate(withDuration: 0.3, animations: {
                if velocity.x > 0 {
                    self.leftMargainConstraint.constant = self.view.frame.size.width - 50
                    
                } else {
                    self.leftMargainConstraint.constant = 0
                }
                self.view.layoutIfNeeded()
            })
        }
    }
}
