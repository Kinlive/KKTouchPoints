//
//  TouchPoint.swift
//  TestForPointOnView
//
//  Created by Kinlive on 2018/3/7.
//  Copyright © 2018年 Kinlive. All rights reserved.
//

import UIKit

@objc public protocol TouchPointViewDelegates: class {
  
  func emptyFunction1()
  
  func emptyFunction2()
  
  func emptyFunction3()
  
  @objc optional func emptyFunction4()
  
  @objc optional func emptyFunction5()
  //MARK: - 為了限制在第一次載入時，拖動touch points出現動作異常
  func currentLocation(currentPoint : CGPoint)
  //MARK: - It's optional func can use or not.

  @objc optional func emptyFunction6()
  
  @objc optional func emptyFunction7()
  
  @objc optional func emptyFunction8()
}


public class TouchPointView: UIView {
  enum PointState {
    case open
    case close
  }

  //MARK: - Delegate func for give which button's action.
  public var delegate: TouchPointViewDelegates?
  //MARK: - Will put on where superViewController.
  public var superViewController: UIViewController!

  private var howMuchPoints: Int = 5
  private var pointsNames: [String] = ["后退", "清除\n缓存", "首页", "刷新", "前进"]
  private var allPoints: [UIButton] = []
  private var pointCurrentState = PointState.close

  private var dragGesture: UIPanGestureRecognizer!
  private var tapGesture: UITapGestureRecognizer!

  private var ignoreDrag = false

  //MARK: - Change  center point's color.
  public var pointColor = UIColor.gray.withAlphaComponent(0.7)
  
  //MARK: - Change center point's border color.
  public var borderColor: CGColor = UIColor.white.cgColor
  
  //MARK: - Change all button's color.
  public var btnPointColor: UIColor = .darkGray
  
  override public init(frame: CGRect) {
    super.init(frame: frame)

    // setupTheTouchPointView()
  }

  required public init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  
  //MARK: - Must to setup name and points count when init touch point.
  public func setupPoints(number: Int, pointsTitles: [String], pointColor: UIColor, buttonsColor: UIColor){
    if number == pointsTitles.count {
      howMuchPoints = number
      pointsNames = pointsTitles
    } else {
      fatalError("Parameters 'number' must equal with 'pointsTitles' count.")
    }
    
    self.pointColor = pointColor
    btnPointColor = buttonsColor
    
    setupTheTouchPointView()
  }
  //MARK: - Must use on viewDidAppear to get correct frame of super view.
  public func onDidAppearSutup() {
    configuresPointOfButton()
    tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapGesture(recongnizer:)))
    tapGesture.numberOfTapsRequired = 1

    dragGesture = UIPanGestureRecognizer(target: self, action: #selector(checkStatusOnWillDragPoint(recognizer:)))
    dragGesture.minimumNumberOfTouches = 1
    dragGesture.maximumNumberOfTouches = 1
    addGestureRecognizer(dragGesture)
    addGestureRecognizer(tapGesture)

    isUserInteractionEnabled = true
    layer.cornerRadius = frame.height / 2
    clipsToBounds = true
    // 一定要加在這先刷新一次 btn位置
    //        pointsOnLeftHalfSide()
    let pointOnWhere = checkPositionOnWhere(position: center)
    for (i, btn) in allPoints.enumerated() {
      DispatchQueue.main.async {
        self.movePointsWith(pointCenter: self.center, i: i, btn: btn, pointsOnWhere: pointOnWhere)
      }
    }
  }

  private func setupTheTouchPointView() {
    guard let aSuperView = superViewController.view else { return }

    layer.borderColor = borderColor
    layer.borderWidth = 3
    backgroundColor = pointColor
    aSuperView.addSubview(self)
    onDidAppearSutup()
    
  }

  @objc private func onTapGesture(recongnizer _: UITapGestureRecognizer) {
    switch pointCurrentState {
    case .open:

      animatePointsWhenHidden(completion: nil)
      pointCurrentState = .close

    case .close:

      animatePointsWhenShow(completion: nil)
      pointCurrentState = .open
    }
  }

  @objc private func checkStatusOnWillDragPoint(recognizer: UIPanGestureRecognizer) {
    if pointCurrentState == .open {
      
      for btn in allPoints {
        btn.isHidden = true
        btn.center = center
      }
      self.onDragPoint(recognizer: recognizer)
      self.pointCurrentState = .close
      
    } else {
      onDragPoint(recognizer: recognizer)
    }
  }

  @objc private func onDragPoint(recognizer: UIPanGestureRecognizer) {
    let position = recognizer.location(in: superViewController.view)

    if !ignoreDrag {
      
      if position.x <= superViewController.view.frame.width * 11 / 12,
        position.x >= superViewController.view.frame.width * 1 / 12 {
        center.x += position.x - center.x
      }
      
      if position.y >= frame.height * 1.4,
        position.y <= superViewController.view.frame.height - frame.height * 1.4 {
        center.y += position.y - center.y
      }
    }

    switch recognizer.state {
    case .began:
      _ = "Here nothing to do"
    case .changed:
      _ = "Here nothing to do"
    case .ended:
      let wherePoint = checkPositionOnWhere(position: position)
      if wherePoint == .none {
        UIView.animate(withDuration: 0.2,
                       delay: 0.1,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.2,
                       options: .curveEaseIn,
                       animations: {
                         self.checkIsOutOfRange(position: position)

                       }, completion: { _ in

        })
      }

      delegate?.currentLocation(currentPoint: self.frame.origin)
      ignoreDrag = false
    default:
      break
    }
  }

  private func checkIsOutOfRange(position _: CGPoint) {
    guard let aSuperView = superViewController.view else { return }

    if center.x + frame.width >= aSuperView.frame.width { // 超出右邊
      center.x = aSuperView.frame.width * 9 / 10
      ignoreDrag = true

    } else if center.x <= frame.width { // 超出左邊
      center.x = superViewController.view.frame.width * 1 / 10
      ignoreDrag = true
    }

    if center.y <= frame.height * 1.4 { // 超出上面
      center.y = frame.height * 2
      ignoreDrag = true

    } else if center.y >= aSuperView.frame.height - frame.height * 1.6 { // 超出下邊
      center.y = aSuperView.frame.height - frame.height * 2
      ignoreDrag = true
    }
  }

  //MARK: - Configure all points of buttons.
   private func configuresPointOfButton() {
    let btnActions = [#selector(emptyFunction1),
                      #selector(emptyFunction2),
                      #selector(emptyFunction3),
                      #selector(emptyFunction4),
                      #selector(emptyFunction5),
                      #selector(emptyFunction6),
                      #selector(emptyFunction7),
                      #selector(emptyFunction8)]
    
    for i in 0..<howMuchPoints{
      let btn = UIButton(type: .system)
      btn.addTarget(self, action: btnActions[i], for: .touchUpInside)
      btn.titleLabel?.lineBreakMode = .byWordWrapping
      btn.setTitle(pointsNames[i], for: .normal)
      btn.frame = frame
      if howMuchPoints > 5,
        howMuchPoints <= 7 {
        btn.frame.size = CGSize(width: frame.width / 1.2,
                                height: frame.height / 1.2)
      } else if howMuchPoints >= 8 {
        btn.frame.size = CGSize(width: frame.width / 1.5,
                                height: frame.height / 1.5)
      }
      
      btn.setTitleColor(.white, for: .normal)
      btn.backgroundColor = btnPointColor
      btn.layer.cornerRadius = btn.frame.height / 2
      btn.clipsToBounds = true
      btn.isHidden = true
      superViewController.view.addSubview(btn)
      allPoints.append(btn)
      
    }

  }

  // MARK: - Animate points on show
  private func animatePointsWhenShow(completion: CompletionHandler?) {
    let pointCenter = center
    let pointsOnWhere = checkPositionOnWhere(position: pointCenter)
    for btn in allPoints {
      btn.center = pointCenter
    }
    for (i, btn) in allPoints.enumerated() {
      UIView.animate(withDuration: 0.2,
                     delay: 0.1 * Double(i),
                     usingSpringWithDamping: 0.8,
                     initialSpringVelocity: 0,
                     options: UIViewAnimationOptions.curveEaseIn,
                     animations: {
                       btn.isHidden = false
                      self.movePointsWith(pointCenter: pointCenter, i: i, btn: btn, pointsOnWhere: pointsOnWhere)

                     }, completion: { _ in
                      if let completion = completion {
                        completion(true)
                      }
      })
    }
  }

  // MARK: - Control the points position.
  private func movePointsWith(pointCenter: CGPoint, i: Int, btn: UIButton, pointsOnWhere: PointPostion) {
    let pointDistance = frame.width
    
    let pointsAngleCount: Double = Double(howMuchPoints - 1)
    
    switch pointsOnWhere {
    case .leftTop:
      let xPo = CGFloat(cos(0 + (Double.pi / (2 * pointsAngleCount) * Double(i))))
      let yPo = CGFloat(sin(0 + (Double.pi / (2 * pointsAngleCount) * Double(i))))
      btn.center = CGPoint(x: pointCenter.x + (pointDistance * 3 * xPo),
                           y: pointCenter.y + (pointDistance * 3 * yPo))
    case .middleTop:
      let xPo = CGFloat(cos(0 + (Double.pi / pointsAngleCount * Double(i))))
      let yPo = CGFloat(sin(0 + (Double.pi / pointsAngleCount * Double(i))))
      btn.center = CGPoint(x: pointCenter.x + (pointDistance * 2 * xPo),
                           y: pointCenter.y + (pointDistance * 2 * yPo))
    case .rightTop:
      let xPo = CGFloat(cos(Double.pi / 2 + (Double.pi / (2 * pointsAngleCount) * Double(i))))
      let yPo = CGFloat(sin(Double.pi / 2 + (Double.pi / (2 * pointsAngleCount) * Double(i))))
      btn.center = CGPoint(x: pointCenter.x + (pointDistance * 3 * xPo),
                           y: pointCenter.y + (pointDistance * 3 * yPo))
    case .leftMiddle:
      let xPo = CGFloat(cos(Double.pi / 2 + (Double.pi / pointsAngleCount * Double(i))))
      let yPo = CGFloat(sin(Double.pi / 2 + (Double.pi / pointsAngleCount * Double(i))))
      btn.center = CGPoint(x: pointCenter.x - (pointDistance * 2 * xPo),
                           y: pointCenter.y + (pointDistance * 2 * yPo))
    case .middle:
      if pointCenter.x >= superViewController.view.frame.width / 2 {
        let xPo = CGFloat(cos(Double.pi / 2 + (Double.pi / pointsAngleCount * Double(i))))
        let yPo = CGFloat(sin(Double.pi / 2 + (Double.pi / pointsAngleCount * Double(i))))
        btn.center = CGPoint(x: pointCenter.x + (pointDistance * 2 * xPo),
                             y: pointCenter.y + (pointDistance * 2 * yPo))
      } else {
        let xPo = CGFloat(cos(Double.pi / 2 + (Double.pi / pointsAngleCount * Double(i))))
        let yPo = CGFloat(sin(Double.pi / 2 + (Double.pi / pointsAngleCount * Double(i))))
        btn.center = CGPoint(x: pointCenter.x - (pointDistance * 2 * xPo),
                             y: pointCenter.y + (pointDistance * 2 * yPo))
      }
    case .rightMiddle:
      let xPo = CGFloat(cos(Double.pi / 2 + (Double.pi / pointsAngleCount * Double(i))))
      let yPo = CGFloat(sin(Double.pi / 2 + (Double.pi / pointsAngleCount * Double(i))))
      btn.center = CGPoint(x: pointCenter.x + (pointDistance * 2 * xPo),
                           y: pointCenter.y + (pointDistance * 2 * yPo))
    case .leftBottom:
      let xPo = CGFloat(cos(-Double.pi / 2 + (Double.pi / (2 * pointsAngleCount) * Double(i))))
      let yPo = CGFloat(sin(-Double.pi / 2 + (Double.pi / (2 * pointsAngleCount) * Double(i))))
      btn.center = CGPoint(x: pointCenter.x + (pointDistance * 3 * xPo),
                           y: pointCenter.y + (pointDistance * 3 * yPo))
    case .middleBottom:
      let xPo = CGFloat(cos(Double.pi + (Double.pi / pointsAngleCount * Double(i))))
      let yPo = CGFloat(sin(Double.pi + (Double.pi / pointsAngleCount * Double(i))))
      btn.center = CGPoint(x: pointCenter.x + (pointDistance * 2 * xPo),
                           y: pointCenter.y + (pointDistance * 2 * yPo))
    case .rightBottom:
      let xPo = CGFloat(cos(Double.pi + (Double.pi / (2 * pointsAngleCount) * Double(i))))
      let yPo = CGFloat(sin(Double.pi + (Double.pi / (2 * pointsAngleCount) * Double(i))))
      btn.center = CGPoint(x: pointCenter.x + (pointDistance * 3 * xPo),
                           y: pointCenter.y + (pointDistance * 3 * yPo))
    case .none:
      btn.isHidden = true
      break
    }
  }

  private typealias CompletionHandler = (Bool) -> Void

  // MARK: - Animate points on close.

  private func animatePointsWhenHidden(completion: CompletionHandler?) {
    for (i, btn) in allPoints.enumerated() {
      UIView.animate(withDuration: 0.2,
                     delay: 0.1 * Double(i),
                     usingSpringWithDamping: 0.8,
                     initialSpringVelocity: 0,
                     options: UIViewAnimationOptions.curveEaseIn,
                     animations: {
                       let pointCenter = self.center
                       btn.center = pointCenter
                     }, completion: { end in
                      if end {
                        btn.isHidden = true
                      }
                      
                      
                      
      })
    }
    if let completion = completion {
      completion(true)
    }
  }

  enum PointPostion: String {
    case leftTop
    case middleTop
    case rightTop
    case leftMiddle
    case middle
    case rightMiddle
    case leftBottom
    case middleBottom
    case rightBottom
    case none
  }

  // MARK: - 判斷當前position的位置

  private func checkPositionOnWhere(position: CGPoint) -> PointPostion {
    // 以九宮格區隔判斷.
    let originX: CGFloat = 0 // 0 ~ view.frame.width/3
    let originY: CGFloat = 0 // 0 ~ view.frame.height/3
    let leftMiddleX = frame.width * 3//superViewController.view.frame.width / 5 // view.frame.width/3 ~ view.frame.width*2/3
    
    let rightMiddleX = superViewController.view.frame.width - frame.width * 3 // view.frame.width*2/3 ~ view.frame.width

    let topMiddleY = superViewController.view.frame.height / 5 //
    let bottomMiddleY = superViewController.view.frame.height * 4 / 5

    // 初次判斷是否在螢幕範圍內
    if position.x - frame.width / 2 >= 0,
      position.x + frame.width / 2 <= superViewController.view.frame.width,
      position.y - frame.height / 2 >= 0,
      position.y + frame.height / 2 <= superViewController.view.frame.height {
      // Point 未貼近上下左右側時 可持續移動
      // 上排 左中右
      if position.y >= originY,
        position.y < topMiddleY {
        if position.x >= originX,
          position.x < leftMiddleX {
          return .leftTop
        }

        if position.x >= leftMiddleX,
          position.x < rightMiddleX {
          return .middleTop
        }

        if position.x >= rightMiddleX,
          position.x < superViewController.view.frame.width {
          return .rightTop
        }
      }

      // 中排 左中右
      if position.y >= topMiddleY,
        position.y < bottomMiddleY {
        if position.x >= originX,
          position.x < leftMiddleX {
          return .leftMiddle
        }

        if position.x >= leftMiddleX,
          position.x < rightMiddleX {
          return .middle
        }

        if position.x >= rightMiddleX,
          position.x < superViewController.view.frame.width {
          return .rightMiddle
        }
      }

      // 下排 左中右
      if position.y >= bottomMiddleY,
        position.y < superViewController.view.frame.height {
        if position.x >= originX,
          position.x < leftMiddleX {
          return .leftBottom
        }

        if position.x >= leftMiddleX,
          position.x < rightMiddleX {
          return .middleBottom
        }

        if position.x >= rightMiddleX,
          position.x < superViewController.view.frame.width {
          return .rightBottom
        }
      }
    }
    // 超出螢幕外的處理
    return .none
  }

  //MARK: - Put which function you want to do for buttons.
  @objc func emptyFunction1() {
    animatePointsWhenHidden { end in
      self.delegate?.emptyFunction1()
      self.pointCurrentState = .close
    }
    
  }
  //MARK: - Put which function you want to do for buttons.
  @objc func emptyFunction2() {
    animatePointsWhenHidden { end in
      self.delegate?.emptyFunction2()
      self.pointCurrentState = .close
    }
    
  }
  //MARK: - Put which function you want to do for buttons.
  @objc func emptyFunction3() {
    animatePointsWhenHidden { end in
      self.delegate?.emptyFunction3()
      self.pointCurrentState = .close
    }
  }
  //MARK: - Put which function you want to do for buttons.
  @objc func emptyFunction4() {
    
    animatePointsWhenHidden { end in
      self.delegate?.emptyFunction4?()
      self.pointCurrentState = .close
    }
  }
  //MARK: - Put which function you want to do for buttons.
  @objc func emptyFunction5() {
    animatePointsWhenHidden { end in
      self.delegate?.emptyFunction5?()
      self.pointCurrentState = .close
    }
    
  }
  
  //MARK: - Put which function you want to do for buttons.
  @objc func emptyFunction6(){
    animatePointsWhenHidden { end in
      self.delegate?.emptyFunction6?()
      self.pointCurrentState = .close
    }
  }
  //MARK: - Put which function you want to do for buttons.
  @objc func emptyFunction7(){
    animatePointsWhenHidden { end in
      self.delegate?.emptyFunction7?()
      self.pointCurrentState = .close
    }
  }
  //MARK: - Put which function you want to do for buttons.
  @objc func emptyFunction8(){
    animatePointsWhenHidden { end in
      self.delegate?.emptyFunction8?()
      self.pointCurrentState = .close
    }
  }
}


