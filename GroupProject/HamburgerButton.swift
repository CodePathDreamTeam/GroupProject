

import UIKit

@objc
@IBDesignable
open class HamburgerButton: UIButton {
    
    fileprivate var animateDuration: CFTimeInterval = 0.5
    fileprivate var strokeWidth: CGFloat = 4.0
    
    @objc
    @IBInspectable open var lineColor: UIColor = UIColor.black {
        didSet {
            if isInitialized {
                _rightLayer.strokeColor = lineColor.cgColor
                _leftLayer.strokeColor = lineColor.cgColor
                _topLayer.strokeColor = lineColor.cgColor
                _middleLayer.strokeColor = lineColor.cgColor
                _bottomLayer.strokeColor = lineColor.cgColor
            }
        }
    }
    
    @objc
    @IBInspectable open var viewColor: UIColor = UIColor.lightGray {
        didSet {
            if isInitialized {
                _circleLayer.fillColor = viewColor.cgColor
            }
        }
    }
    
    // when using interface inspector to set, the didSet
    // is called after the button initializes, so need to
    // keep it to check for proper init
    fileprivate var isInitialized = false
    @objc
    @IBInspectable internal var isMenu: Bool = true {
        didSet {
            if !isInitialized {
                // If this is called before init, so can ignore
                // commonInit() has not happened yet
            }
            else
            {
                configButton()
            }
        }
    }
    
    @objc  // alternate the animation pattern
    @IBInspectable open var alternateAni: Bool = false
    
    // this keeps track of if inv path is loaded
    // true if loaded
    fileprivate var isInv = false
    @objc // invert the animation pattern
    @IBInspectable var invertAni: Bool = false
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    // MARK: Interface Builder
    override open func awakeFromNib() {
        commonInit()
    }
    
    // MARK: Live Render #if TARGET_INTERFACE_BUILDER
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
    }
    
    // the button will keep track of own state with button
    // presses. Can programmatically set button with isMenu property
    // but should not set in response to an event from an outlet
    func touchUpInside(_ sender: UIButton, event: UIEvent) {
        isMenu = !isMenu
    }
    
    fileprivate func configButton() {
        
        if isMenu {
            print("menu")
            makeBurger()
        } else {
            makeCancelX()
            print("cancel")
        }
    }
    
    fileprivate func makeBurger() {
        
        if alternateAni {
            isInv = !isInv
            if isInv {
                // load inverse
                _rightLayer.path = self._rightPathInv
                _leftLayer.path = self._leftPathInv
            }
            else {
                // load normal
                _rightLayer.path = self._rightPath
                _leftLayer.path = self._leftPath
            }
        }
        
        _middleLayer.add(_makeXforGroupMiddle, forKey: "makeaburger")
        _topLayer.add(_makeXforGroupTop, forKey: "makeaburger")
        _bottomLayer.add(_makeXforGroupBottom, forKey: "makeaburger")
        _rightLayer.add(_makeXforGroupX, forKey: "makeaburger")
        _leftLayer.add(_makeXforGroupX, forKey: "makeaburger")
    }
    
    fileprivate func makeCancelX() {
        
        if alternateAni {
            isInv = !isInv
            if isInv {
                // load inverse
                _rightLayer.path = self._rightPathInv
                _leftLayer.path = self._leftPathInv
            }
            else {
                // load normal
                _rightLayer.path = self._rightPath
                _leftLayer.path = self._leftPath
            }
        }
        
        _middleLayer.add(_makeMenuforGroupMiddle, forKey: "makeacross")
        _topLayer.add(_makeMenuforGroupTop, forKey: "makeacross")
        _bottomLayer.add(_makeMenuforGroupBottom, forKey: "makeacross")
        _rightLayer.add(_makeMenuforGroupX, forKey: "makeacross")
        _leftLayer.add(_makeMenuforGroupX, forKey: "makeacross")
        
    }
    
    fileprivate func commonInit() {
        _loadLayers()
        layoutSubviews()
        
        let space = fmin(frame.size.width, frame.size.height)
        strokeWidth = ceil(space * 0.08)
        
        self.addTarget(self, action: #selector(HamburgerButton.touchUpInside(_:event:)), for: .touchUpInside)
        
        if isMenu {
            
            // set up for menu button
            _rightLayer.strokeStart = 0.0
            _rightLayer.strokeEnd =  msLen / lsLen
            
            _leftLayer.strokeStart = 0.0
            _leftLayer.strokeEnd =   msLen / lsLen
            
            _topLayer.path = _topPath
            _middleLayer.path = _middlePath
            _bottomLayer.path = _bottomPath
            
            _topLayer.isHidden = false
            _middleLayer.isHidden = false
            _bottomLayer.isHidden = false
        }
        else {
            
            // set up for cancel button X lines
            _rightLayer.strokeStart = 1.0 - (cwLen / lsLen) - (bxLen / lsLen)
            _rightLayer.strokeEnd =   1.0 - (bxLen / lsLen)
            
            _leftLayer.strokeStart = 1.0 - (cwLen / lsLen) - (bxLen / lsLen)
            _leftLayer.strokeEnd =   1.0 - (bxLen / lsLen)
            
            _topLayer.path = _middlePath
            _bottomLayer.path = _middlePath
            
            _topLayer.isHidden = true
            _middleLayer.isHidden = true
            _bottomLayer.isHidden = true
            _leftLayer.isHidden = false
            _rightLayer.isHidden = false
        }
        
        makeBurgerAnimations()
        makeCancelXAnimations()
        
        isInitialized = true
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        if _circleLayer.superlayer != layer {
            layer.addSublayer(_circleLayer)
        }
        
        if _topLayer.superlayer != layer {
            layer.addSublayer(_topLayer)
        }
        
        if _middleLayer.superlayer != layer {
            layer.addSublayer(_middleLayer)
        }
        
        if _bottomLayer.superlayer != layer {
            layer.addSublayer(_bottomLayer)
        }
        
        if _rightLayer.superlayer != layer {
            layer.addSublayer(_rightLayer)
        }
        
        if _leftLayer.superlayer != layer {
            layer.addSublayer(_leftLayer)
        }
    }
    
    fileprivate var _makeXforGroupX: CAAnimationGroup!
    fileprivate var _makeXforGroupTop: CAAnimationGroup!
    fileprivate var _makeXforGroupMiddle: CAAnimationGroup!
    fileprivate var _makeXforGroupBottom: CAAnimationGroup!
    
    fileprivate var _makeMenuforGroupX: CAAnimationGroup!
    fileprivate var _makeMenuforGroupTop: CAAnimationGroup!
    fileprivate var _makeMenuforGroupMiddle: CAAnimationGroup!
    fileprivate var _makeMenuforGroupBottom: CAAnimationGroup!
    
    fileprivate var _rightLayer: CAShapeLayer!
    fileprivate var _leftLayer: CAShapeLayer!
    fileprivate var _topLayer: CAShapeLayer!
    fileprivate var _middleLayer: CAShapeLayer!
    fileprivate var _bottomLayer: CAShapeLayer!
    fileprivate var _circleLayer: CAShapeLayer!
    
    fileprivate func _loadLayers() {
        
        _rightLayer = CAShapeLayer()
        _rightLayer.isHidden = true
        _rightLayer.path = _rightPath
        
        _leftLayer = CAShapeLayer()
        _leftLayer.isHidden = true
        _leftLayer.path = _leftPath
        
        _topLayer = CAShapeLayer()
        _topLayer.path = _topPath
        
        _middleLayer = CAShapeLayer()
        _middleLayer.path = _middlePath
        
        _bottomLayer = CAShapeLayer()
        _bottomLayer.path = _bottomPath
        
        _circleLayer = CAShapeLayer()
        _circleLayer.path = _circlePath
        _circleLayer.strokeColor = nil
        _circleLayer.fillColor = viewColor.cgColor
        isInv = false
        if invertAni {
            _rightLayer.path = self._rightPathInv
            _leftLayer.path = self._leftPathInv
            isInv = true
        }
        
        let buttonLayers = [_rightLayer, _leftLayer, _topLayer, _middleLayer, _bottomLayer]
        
        let space = fmin(frame.size.width, frame.size.height)
        let strokeWidth = ceil(space * 0.08)
        
        for layer in buttonLayers {
            
            layer?.fillColor = nil
            layer?.strokeColor = lineColor.cgColor
            layer?.lineWidth = strokeWidth
            layer?.lineCap = kCALineCapRound
        }
    }
    
    fileprivate var _rightPath: CGPath {
        let rightPath = UIBezierPath()
        
        rightPath.move(to: CGPointMakeWithScale(10, y: 25))
        rightPath.addLine(to: CGPointMakeWithScale(40, y: 25))
        rightPath.addLine(to: CGPointMakeWithScale(44.26, y: 25))
        rightPath.addCurve(to: CGPointMakeWithScale(47.74, y: 24.01), controlPoint1: CGPointMakeWithScale(44.26, y: 24.82), controlPoint2: CGPointMakeWithScale(46.52, y: 25.04))
        rightPath.addCurve(to: CGPointMakeWithScale(48.5, y: 22.5), controlPoint1: CGPointMakeWithScale(48.15, y: 23.66), controlPoint2: CGPointMakeWithScale(48.44, y: 23.18))
        rightPath.addCurve(to: CGPointMakeWithScale(48.5, y: 21.32), controlPoint1: CGPointMakeWithScale(48.53, y: 22.16), controlPoint2: CGPointMakeWithScale(48.61, y: 21.77))
        rightPath.addCurve(to: CGPointMakeWithScale(46.76, y: 15.85), controlPoint1: CGPointMakeWithScale(47.72, y: 18.21), controlPoint2: CGPointMakeWithScale(46.76, y: 15.85))
        rightPath.addLine(to: CGPointMakeWithScale(45.22, y: 12.84))
        rightPath.addCurve(to: CGPointMakeWithScale(42.28, y: 9.66), controlPoint1: CGPointMakeWithScale(45.22, y: 12.84), controlPoint2: CGPointMakeWithScale(43.6, y: 10.09))
        rightPath.addCurve(to: CGPointMakeWithScale(39.75, y: 10.08), controlPoint1: CGPointMakeWithScale(41.64, y: 9.45), controlPoint2: CGPointMakeWithScale(40.2, y: 9.63))
        rightPath.addCurve(to: CGPointMakeWithScale(38.64, y: 11.39), controlPoint1: CGPointMakeWithScale(39.15, y: 10.68), controlPoint2: CGPointMakeWithScale(38.64, y: 11.39))
        rightPath.addLine(to: CGPointMakeWithScale(7, y: 43))
        
        return rightPath.cgPath
    }
    
    fileprivate var _rightPathInv: CGPath {
        let rightPath = UIBezierPath()
        
        rightPath.move(to: CGPointMakeWithScale(10, y: 25, inverse: true))
        rightPath.addLine(to: CGPointMakeWithScale(40, y: 25, inverse: true))
        rightPath.addLine(to: CGPointMakeWithScale(44.26, y: 25, inverse: true))
        rightPath.addCurve(to: CGPointMakeWithScale(47.74, y: 24.01, inverse: true), controlPoint1: CGPointMakeWithScale(44.26, y: 24.82, inverse: true), controlPoint2: CGPointMakeWithScale(46.52, y: 25.04, inverse: true))
        rightPath.addCurve(to: CGPointMakeWithScale(48.5, y: 22.5, inverse: true), controlPoint1: CGPointMakeWithScale(48.15, y: 23.66, inverse: true), controlPoint2: CGPointMakeWithScale(48.44, y: 23.18, inverse: true))
        rightPath.addCurve(to: CGPointMakeWithScale(48.5, y: 21.32, inverse: true), controlPoint1: CGPointMakeWithScale(48.53, y: 22.16, inverse: true), controlPoint2: CGPointMakeWithScale(48.61, y: 21.77, inverse: true))
        rightPath.addCurve(to: CGPointMakeWithScale(46.76, y: 15.85, inverse: true), controlPoint1: CGPointMakeWithScale(47.72, y: 18.21, inverse: true), controlPoint2: CGPointMakeWithScale(46.76, y: 15.85, inverse: true))
        rightPath.addLine(to: CGPointMakeWithScale(45.22, y: 12.84, inverse: true))
        rightPath.addCurve(to: CGPointMakeWithScale(42.28, y: 9.66, inverse: true), controlPoint1: CGPointMakeWithScale(45.22, y: 12.84, inverse: true), controlPoint2: CGPointMakeWithScale(43.6, y: 10.09, inverse: true))
        rightPath.addCurve(to: CGPointMakeWithScale(39.75, y: 10.08, inverse: true), controlPoint1: CGPointMakeWithScale(41.64, y: 9.45, inverse: true), controlPoint2: CGPointMakeWithScale(40.2, y: 9.63, inverse: true))
        rightPath.addCurve(to: CGPointMakeWithScale(38.64, y: 11.39, inverse: true), controlPoint1: CGPointMakeWithScale(39.15, y: 10.68, inverse: true), controlPoint2: CGPointMakeWithScale(38.64, y: 11.39, inverse: true))
        rightPath.addLine(to: CGPointMakeWithScale(7, y: 43, inverse: true))
        
        return rightPath.cgPath
    }
    
    fileprivate var _leftPath: CGPath {
        let leftPath = UIBezierPath()
        
        leftPath.move(to: CGPointMakeWithScale(40, y: 25))
        leftPath.addLine(to: CGPointMakeWithScale(10, y: 25))
        leftPath.addLine(to: CGPointMakeWithScale(5.74, y: 25))
        leftPath.addCurve(to: CGPointMakeWithScale(2.26, y: 24.01), controlPoint1: CGPointMakeWithScale(5.74, y: 24.82), controlPoint2: CGPointMakeWithScale(3.48, y: 25.04))
        leftPath.addCurve(to: CGPointMakeWithScale(1.5, y: 22.5), controlPoint1: CGPointMakeWithScale(1.85, y: 23.66), controlPoint2: CGPointMakeWithScale(1.56, y: 23.18))
        leftPath.addCurve(to: CGPointMakeWithScale(1.5, y: 21.32), controlPoint1: CGPointMakeWithScale(1.47, y: 22.16), controlPoint2: CGPointMakeWithScale(1.39, y: 21.77))
        leftPath.addCurve(to: CGPointMakeWithScale(3.24, y: 15.85), controlPoint1: CGPointMakeWithScale(2.28, y: 18.21), controlPoint2: CGPointMakeWithScale(3.24, y: 15.85))
        leftPath.addLine(to: CGPointMakeWithScale(4.78, y: 12.84))
        leftPath.addCurve(to: CGPointMakeWithScale(7.72, y: 9.66), controlPoint1: CGPointMakeWithScale(4.78, y: 12.84), controlPoint2: CGPointMakeWithScale(6.4, y: 10.09))
        leftPath.addCurve(to: CGPointMakeWithScale(10.25, y: 10.08), controlPoint1: CGPointMakeWithScale(8.36, y: 9.45), controlPoint2: CGPointMakeWithScale(9.8, y: 9.63))
        leftPath.addCurve(to: CGPointMakeWithScale(11.36, y: 11.39), controlPoint1: CGPointMakeWithScale(10.85, y: 10.68), controlPoint2: CGPointMakeWithScale(11.36, y: 11.39))
        leftPath.addLine(to: CGPointMakeWithScale(43, y: 43))
        
        return leftPath.cgPath
    }
    
    fileprivate var _leftPathInv: CGPath {
        let leftPath = UIBezierPath()
        
        leftPath.move(to: CGPointMakeWithScale(40, y: 25, inverse: true))
        leftPath.addLine(to: CGPointMakeWithScale(10, y: 25, inverse: true))
        leftPath.addLine(to: CGPointMakeWithScale(5.74, y: 25, inverse: true))
        leftPath.addCurve(to: CGPointMakeWithScale(2.26, y: 24.01, inverse: true), controlPoint1: CGPointMakeWithScale(5.74, y: 24.82, inverse: true), controlPoint2: CGPointMakeWithScale(3.48, y: 25.04, inverse: true))
        leftPath.addCurve(to: CGPointMakeWithScale(1.5, y: 22.5, inverse: true), controlPoint1: CGPointMakeWithScale(1.85, y: 23.66, inverse: true), controlPoint2: CGPointMakeWithScale(1.56, y: 23.18, inverse: true))
        leftPath.addCurve(to: CGPointMakeWithScale(1.5, y: 21.32, inverse: true), controlPoint1: CGPointMakeWithScale(1.47, y: 22.16, inverse: true), controlPoint2: CGPointMakeWithScale(1.39, y: 21.77, inverse: true))
        leftPath.addCurve(to: CGPointMakeWithScale(3.24, y: 15.85, inverse: true), controlPoint1: CGPointMakeWithScale(2.28, y: 18.21, inverse: true), controlPoint2: CGPointMakeWithScale(3.24, y: 15.85, inverse: true))
        leftPath.addLine(to: CGPointMakeWithScale(4.78, y: 12.84, inverse: true))
        leftPath.addCurve(to: CGPointMakeWithScale(7.72, y: 9.66, inverse: true), controlPoint1: CGPointMakeWithScale(4.78, y: 12.84, inverse: true), controlPoint2: CGPointMakeWithScale(6.4, y: 10.09, inverse: true))
        leftPath.addCurve(to: CGPointMakeWithScale(10.25, y: 10.08, inverse: true), controlPoint1: CGPointMakeWithScale(8.36, y: 9.45, inverse: true), controlPoint2: CGPointMakeWithScale(9.8, y: 9.63, inverse: true))
        leftPath.addCurve(to: CGPointMakeWithScale(11.36, y: 11.39, inverse: true), controlPoint1: CGPointMakeWithScale(10.85, y: 10.68, inverse: true), controlPoint2: CGPointMakeWithScale(11.36, y: 11.39, inverse: true))
        leftPath.addLine(to: CGPointMakeWithScale(43, y: 43, inverse: true))
        
        return leftPath.cgPath
    }
    
    fileprivate var _topPath: CGPath {
        
        let path = UIBezierPath()
        
        // top Menu line Path
        path.move(to: CGPointMakeWithScale(10, y: 12))
        path.addLine(to: CGPointMakeWithScale(40, y: 12))
        
        return path.cgPath
    }
    
    fileprivate var _topPathB: CGPath {
        let path = UIBezierPath()
        
        // top Menu line Bounce Path
        path.move(to: CGPointMakeWithScale(10, y: 10))
        path.addLine(to: CGPointMakeWithScale(40, y: 10))
        
        return path.cgPath
    }
    
    fileprivate var _middlePath: CGPath {
        
        let path = UIBezierPath()
        
        // middle Menu line Path
        path.move(to: CGPointMakeWithScale(10, y: 25))
        path.addLine(to: CGPointMakeWithScale(40, y: 25))
        
        return path.cgPath
    }
    
    fileprivate var _bottomPath: CGPath {
        
        let path = UIBezierPath()
        
        // bottom Menu line Path
        path.move(to: CGPointMakeWithScale(10, y: 38))
        path.addLine(to: CGPointMakeWithScale(40, y: 38))
        
        return path.cgPath
    }
    
    fileprivate var _bottomPathB: CGPath {
        let path = UIBezierPath()
        
        // bottom Menu line Bounce Path
        path.move(to: CGPointMakeWithScale(10, y: 40))
        path.addLine(to: CGPointMakeWithScale(40, y: 40))
        
        return path.cgPath
    }
    
    fileprivate var _circlePath: CGPath {
        
        let radiusScale = CGPointMakeWithScale(25, y: 25)
        
        return UIBezierPath(arcCenter: CGPointMakeWithScale(25, y: 25), radius: fmin(radiusScale.x, radiusScale.y), startAngle: 0.0, endAngle: CGFloat(M_PI * 2.0), clockwise: true).cgPath
    }
    
    fileprivate func CGPointMakeWithScale(_ x: CGFloat, y: CGFloat, inverse: Bool? = false) -> CGPoint {
        
        let ORIGINALSIZE: CGFloat = 50
        
        var foo = x / ORIGINALSIZE
        foo *= frame.size.width
        
        var foo1 = y / ORIGINALSIZE
        
        if inverse! {
            foo1 = (ORIGINALSIZE - y) / ORIGINALSIZE
        }
        
        foo1 *= frame.size.height
        
        return CGPoint(x: foo, y: foo1)
    }
    
    fileprivate let bxLen: CGFloat = 8.5
    fileprivate let cwLen: CGFloat = 85.0
    fileprivate let lsLen: CGFloat = 207.0
    fileprivate let msLen: CGFloat = 60.0
    
    fileprivate func makeBurgerAnimations() {
        
        let repeatCnt: Float = 0.0			// Float.infinity to repeat forver
        let xTime = animateDuration * 0.6		// most of animation spent making X
        let bounceDst =  Double(bxLen)		// the bounce distance
        let barLen =  Double(msLen)			// distance of hamburger bars
        let totalMovement = Double(lsLen)	// total distance to move
        let distanceDelta = totalMovement - barLen - bounceDst	// distance the start or end point will go from start to end
        let timeScale = xTime / distanceDelta	// scale so animation always has same pace
        let totalTimeBouncDst = (totalMovement - barLen) * timeScale // total time to go with bounce distanc
        let bouncTime = totalTimeBouncDst - xTime	// bounce time
        let twoBounceTimes = bouncTime * 2			// double bounce time
        let strokeDelay = animateDuration - xTime		// time for 1st part 2 finish
        let firstAniTime = strokeDelay * 0.95		// safe time to show lt & rt lines
        let menuBounce = firstAniTime * 0.2		// duration of menu bounce
        let delay0 = bouncTime					// delay before strokeEnd moves
        let dur0 = xTime
        let dur1 = twoBounceTimes
        let dur2 = twoBounceTimes + twoBounceTimes
        let delay1 = delay0 + dur2 - bouncTime
        let enddur0 = totalTimeBouncDst
        let durTotal = delay0 + dur0 + dur1 + dur2 + strokeDelay // total duration
        
        let alpMid = CABasicAnimation(keyPath: "hidden")
        
        alpMid.fromValue = true
        alpMid.toValue = false
        alpMid.beginTime = enddur0 + dur1 + delay1 - 0.01
        alpMid.duration = 0.02
        alpMid.isRemovedOnCompletion = false
        alpMid.fillMode = kCAFillModeForwards
        
        let groupMid = CAAnimationGroup()
        
        groupMid.animations = [alpMid]
        groupMid.duration = durTotal
        groupMid.autoreverses = false
        groupMid.repeatCount = repeatCnt
        groupMid.isRemovedOnCompletion = false
        groupMid.fillMode = kCAFillModeForwards
        
        let ani0 = CABasicAnimation.init(keyPath: "path")
        
        ani0.toValue = _topPathB
        ani0.fromValue = _middlePath
        ani0.beginTime = enddur0 + dur1 + delay1
        ani0.duration = menuBounce
        ani0.isRemovedOnCompletion = false
        ani0.fillMode = kCAFillModeForwards
        
        let ani0B = CABasicAnimation.init(keyPath: "path")
        
        ani0B.toValue = _topPath
        ani0B.fromValue = _topPathB
        ani0B.beginTime = ani0.beginTime + ani0.duration
        ani0B.duration = firstAniTime - menuBounce
        ani0B.isRemovedOnCompletion = false
        ani0B.fillMode = kCAFillModeForwards
        
        let ani1 = CABasicAnimation.init(keyPath: "path")
        
        ani1.toValue = _bottomPathB
        ani1.fromValue = _middlePath
        ani1.beginTime = enddur0 + dur1 + delay1
        ani1.duration = menuBounce
        ani1.isRemovedOnCompletion = false
        ani1.fillMode = kCAFillModeForwards
        
        let ani1B = CABasicAnimation.init(keyPath: "path")
        
        ani1B.toValue = _bottomPath
        ani1B.fromValue = _bottomPathB
        ani1B.beginTime = ani1.beginTime + ani1.duration
        ani1B.duration = firstAniTime - menuBounce
        ani1B.isRemovedOnCompletion = false
        ani1B.fillMode = kCAFillModeForwards
        
        let groupTop = CAAnimationGroup()
        
        groupTop.animations = [ani0, ani0B, alpMid]
        groupTop.duration = durTotal
        groupTop.autoreverses = false
        groupTop.repeatCount = repeatCnt
        groupTop.isRemovedOnCompletion = false
        groupTop.fillMode = kCAFillModeForwards
        
        let groupBottom = CAAnimationGroup()
        
        groupBottom.animations = [ani1, ani1B, alpMid]
        groupBottom.duration = durTotal
        groupBottom.autoreverses = false
        groupBottom.repeatCount = repeatCnt
        groupBottom.isRemovedOnCompletion = false
        groupBottom.fillMode = kCAFillModeForwards
        
        let end1 = CABasicAnimation(keyPath: "strokeEnd")
        
        end1.toValue = 1.0
        end1.fromValue = 1.0 - (bxLen / lsLen)
        end1.beginTime = delay1
        end1.duration = dur1
        end1.isRemovedOnCompletion = false
        end1.fillMode = kCAFillModeForwards
        
        let end0 = CABasicAnimation(keyPath: "strokeEnd")
        
        end0.toValue = msLen / lsLen
        end0.fromValue = 1.0
        end0.beginTime = end1.beginTime + end1.duration
        end0.duration = enddur0
        end0.isRemovedOnCompletion = false
        end0.fillMode = kCAFillModeForwards
        
        let start2 = CABasicAnimation(keyPath: "strokeStart")
        
        start2.toValue = 1.0 - (cwLen / lsLen) + (bxLen / lsLen)
        start2.fromValue = 1.0 - (cwLen / lsLen) - (bxLen / lsLen)
        start2.beginTime = 0.0
        start2.duration = dur2
        start2.isRemovedOnCompletion = false
        start2.fillMode = kCAFillModeForwards
        
        let start1 = CABasicAnimation(keyPath: "strokeStart")
        
        start1.toValue = 1.0 - (cwLen / lsLen) - (bxLen / lsLen)
        start1.fromValue = 1.0 - (cwLen / lsLen) + (bxLen / lsLen)
        start1.beginTime = start2.beginTime + start2.duration
        start1.duration = dur1
        start1.isRemovedOnCompletion = false
        start1.fillMode = kCAFillModeForwards
        
        let start0 = CABasicAnimation(keyPath: "strokeStart")
        start0.toValue = 0.0
        start0.fromValue = 1.0 - (cwLen / lsLen) - (bxLen / lsLen)
        start0.beginTime = start1.beginTime + start1.duration
        start0.duration = dur0
        start0.isRemovedOnCompletion = false
        start0.fillMode = kCAFillModeForwards
        
        let alp = CABasicAnimation(keyPath: "hidden")
        
        alp.toValue = true
        alp.fromValue = false
        alp.beginTime = enddur0 + dur1 + delay1
        alp.duration = 0.1
        alp.isRemovedOnCompletion = false
        alp.fillMode = kCAFillModeForwards
        
        let groupX = CAAnimationGroup()
        
        groupX.animations = [end1, end0, start2, start1, start0, alp]
        groupX.duration = durTotal
        
        groupX.autoreverses = false
        groupX.repeatCount = repeatCnt
        groupX.isRemovedOnCompletion = false
        groupX.fillMode = kCAFillModeForwards
        
        _makeXforGroupX = groupX
        _makeXforGroupTop = groupTop
        _makeXforGroupMiddle = groupMid
        _makeXforGroupBottom = groupBottom
        
    }
    
    fileprivate func makeCancelXAnimations() {
        
        
        let repeatCnt: Float = 0.0			// Float.infinity to repeat forver
        let xTime = animateDuration * 0.6		// most of animation spent making X
        let bounceDst =  Double(bxLen)		// the bounce distance
        let barLen =  Double(msLen)			// distance of hamburger bars
        let totalMovement = Double(lsLen)	// total distance to move
        let distanceDelta = totalMovement - barLen - bounceDst	// distance the start or end point will go from start to end
        let timeScale = xTime / distanceDelta	// scale so animation always has same pace
        let totalTimeBouncDst = (totalMovement - barLen) * timeScale // total time to go with bounce distanc
        let bouncTime = totalTimeBouncDst - xTime	// bounce time
        let twoBounceTimes = bouncTime * 2			// double bounce time
        let strokeDelay = animateDuration - xTime		// time for 1st part 2 finish
        let firstAniTime = strokeDelay * 0.95		// safe time to show lt & rt lines
        let showCross = strokeDelay * 0.98		// when to make the X lines visible
        let delay0 = bouncTime					// delay before strokeEnd moves
        let dur0 = xTime
        let dur1 = twoBounceTimes
        let dur2 = twoBounceTimes + twoBounceTimes
        let delay1 = delay0 + dur2 - bouncTime
        let enddur0 = totalTimeBouncDst
        let durTotal = delay0 + dur0 + dur1 + dur2 + strokeDelay // total duration
        
        let alpMid = CABasicAnimation(keyPath: "hidden")
        
        alpMid.fromValue = false
        alpMid.toValue = true
        alpMid.beginTime = strokeDelay
        alpMid.duration = 0.02
        alpMid.isRemovedOnCompletion = false
        alpMid.fillMode = kCAFillModeForwards
        
        let groupMid = CAAnimationGroup()
        
        groupMid.animations = [alpMid]
        groupMid.duration = durTotal
        groupMid.autoreverses = false
        groupMid.repeatCount = repeatCnt
        groupMid.isRemovedOnCompletion = false
        groupMid.fillMode = kCAFillModeForwards
        
        let ani0 = CABasicAnimation.init(keyPath: "path")
        
        ani0.fromValue = _topPath
        ani0.toValue = _middlePath
        ani0.beginTime = 0.0
        ani0.duration = firstAniTime
        ani0.isRemovedOnCompletion = false
        ani0.fillMode = kCAFillModeForwards
        
        let ani1 = CABasicAnimation.init(keyPath: "path")
        
        ani1.fromValue = _bottomPath
        ani1.toValue = _middlePath
        ani1.beginTime = 0.0
        ani1.duration = firstAniTime
        ani1.isRemovedOnCompletion = false
        ani1.fillMode = kCAFillModeForwards
        
        let groupTop = CAAnimationGroup()
        
        groupTop.animations = [ani0, alpMid]
        groupTop.duration = durTotal
        groupTop.autoreverses = false
        groupTop.repeatCount = repeatCnt
        groupTop.isRemovedOnCompletion = false
        groupTop.fillMode = kCAFillModeForwards
        
        let groupBottom = CAAnimationGroup()
        
        groupBottom.animations = [ani1, alpMid]
        groupBottom.duration = durTotal
        groupBottom.autoreverses = false
        groupBottom.repeatCount = repeatCnt
        groupBottom.isRemovedOnCompletion = false
        groupBottom.fillMode = kCAFillModeForwards
        
        let alp = CABasicAnimation(keyPath: "hidden")
        
        alp.fromValue = true
        alp.toValue = false
        alp.beginTime = showCross
        alp.duration = 0.1
        alp.isRemovedOnCompletion = false
        alp.fillMode = kCAFillModeForwards
        
        let start0 = CABasicAnimation(keyPath: "strokeStart")
        
        start0.fromValue = 0.0
        start0.toValue = 1.0 - (cwLen / lsLen) - (bxLen / lsLen)
        start0.beginTime = strokeDelay + delay0
        start0.duration = dur0
        start0.isRemovedOnCompletion = false
        start0.fillMode = kCAFillModeForwards
        
        let start1 = CABasicAnimation(keyPath: "strokeStart")
        
        start1.fromValue = 1.0 - (cwLen / lsLen) - (bxLen / lsLen)
        start1.toValue = 1.0 - (cwLen / lsLen) + (bxLen / lsLen)
        start1.beginTime = start0.beginTime + start0.duration
        start1.duration = dur1
        start1.isRemovedOnCompletion = false
        start1.fillMode = kCAFillModeForwards
        
        let start2 = CABasicAnimation(keyPath: "strokeStart")
        
        start2.fromValue = 1.0 - (cwLen / lsLen) + (bxLen / lsLen)
        start2.toValue = 1.0 - (cwLen / lsLen) - (bxLen / lsLen)
        start2.beginTime = start1.beginTime + start1.duration
        start2.duration = dur2
        start2.isRemovedOnCompletion = false
        start2.fillMode = kCAFillModeForwards
        
        let end0 = CABasicAnimation(keyPath: "strokeEnd")
        
        end0.fromValue = msLen / lsLen
        end0.toValue = 1.0
        end0.beginTime = strokeDelay
        end0.duration = enddur0
        end0.isRemovedOnCompletion = false
        end0.fillMode = kCAFillModeForwards
        
        let end1 = CABasicAnimation(keyPath: "strokeEnd")
        
        end1.fromValue = 1.0
        end1.toValue = 1.0 - (bxLen / lsLen)
        end1.beginTime = end0.beginTime + end0.duration + delay1
        end1.duration = dur1
        end1.isRemovedOnCompletion = false
        end1.fillMode = kCAFillModeForwards
        
        let groupX = CAAnimationGroup()
        
        groupX.animations = [alp, start0, start1, start2, end0, end1]
        groupX.duration = durTotal
        groupX.autoreverses = false
        groupX.repeatCount = repeatCnt
        groupX.isRemovedOnCompletion = false
        groupX.fillMode = kCAFillModeForwards
        
        _makeMenuforGroupX = groupX
        _makeMenuforGroupTop = groupTop
        _makeMenuforGroupMiddle = groupMid
        _makeMenuforGroupBottom = groupBottom
        
    }
    
}
