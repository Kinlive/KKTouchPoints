KKTouchPoints
============

## Requirements

iOS 10.0
Swift 4.0

## Usage

1. Make a variable of UIView and inherit TouchPointsView.
2. On your viewDidAppear initialize TouchPointsView, specify delegate, give current viewController for TouchPointsView.superViewController.
3. On your viewDidAppear use function
setupPoints(number: HowMuchPointsYouWantShow, pointsTitles: GiveWhatNameOfYourPointsTitle, pointColor: CenterPointsColor ,buttonsColor: AllButtonsColor ).
4. Implementation with TouchPointViewDelegates require or optional functions.

## Notice

Must declare a variable with currentPosition = CGPoint.zero, it's for delegates func currentLocation(currentPoint: CGPoint) specify the function parameter to your currentPosition, then when viewDidAppear() first initial the touchPoints
if currentPosition == .zero {
touchPoint.frame = CGRect(x: AnyWhere, y: AnyWhere, width: AnySize, height:  AnySize )
} else {
touchPoint.frame = CGRect(x: currentPosition.x, y: currentPosition.y, width: EqualTopSize , height: EqualTopSize)
}
