KKTouchPoints
============

## Requirements

iOS 10.0
Swift 4.0

## Usage

1. Make a variable of UIView and inherit TouchPointsView, declare a varialble of CGPoint.
```
Example
var touchPoints: TouchPointsView!
var currentPosition = CGPoint.zero
```
2. On your viewDidAppear initialize TouchPointsView, specify delegate, give current viewController for TouchPointsView.superViewController.
```
Example
if currentPosition == .zero{
//First entry.
touchPoints = TouchPointView(frame: CGRect(x: view.frame.width - 150, y: view.frame.height / 3, width: view.frame.width / 8, height: view.frame.width / 8))
} else {
  touchPoint.frame = CGRect(x: currentPosition.x, y: currentPosition.y, width: EqualFirstEntrySize , height: EqualFirstEntrySize)
}
touchPoints.delegate = self
touchPoints.superViewController = self
```
3. On your viewDidAppear use function setupPoints().
```
//Number during 1 ~ 8, and **names.count must equal to number**.
touchPoints.setupPoints(number: 8, pointsTitles: ["1111", "22\n22", "3333", "4444", "5555", "6666", "7777", "8888"], pointColor: .red, buttonsColor: .blue)
```
4. Implementation with TouchPointViewDelegates require or optional functions.
```
extension ViewController: TouchPointViewDelegates{

func currentLocation(currentPoint: CGPoint) {
//Specify the parameter to your variable.
self.currentPosition = currentPoint
}

func emptyFunction1() {
//Give action you want to do.
}

func emptyFunction2() {
//Give action you want to do.
}
}
```

### Public variable
1. var delegate: TouchPointViewDelegates?
2. var superViewController: UIViewController!
3. var pointColor: UIColor = .gray.withAlphaComponent(0.7)
4. var borderColor: CGColor = .white.cgColor
5. var btnPointColor: UIColor = .darkGray
