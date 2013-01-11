part of effects;

class FadeEffect extends Css3TransitionEffect {
  FadeEffect() : super('opacity', '0', '1');
}

// TODO: orientation
class ShrinkEffect extends Css3TransitionEffect {
  ShrinkEffect() : super('max-height', '0', '500px', {'overflow': 'hidden'});
}

// TODO: scale to corner
class ScaleEffect extends Css3TransitionEffect {

  factory ScaleEffect({Orientation orientation, HorizontalAlignment xOffset, VerticalAlignment yOffset}) {
    String hideValue;
    switch(orientation) {
      case Orientation.VERTICAL:
        hideValue = 'scale(1, 0)';
        break;
      case Orientation.HORIZONTAL:
        hideValue = 'scale(0, 1)';
        break;
      default:
        hideValue = 'scale(0, 0)';
        break;
    }

    if(xOffset == null) {
      xOffset = HorizontalAlignment.CENTER;
    }
    final xoValue = xOffset.name;

    if(yOffset == null) {
      yOffset = VerticalAlignment.MIDDLE;
    }
    final yoValue = (yOffset == VerticalAlignment.MIDDLE) ? 'center' : yOffset.name;

    final map = {'-webkit-transform-origin' : '$xoValue $yoValue'};

    return new ScaleEffect._internal(hideValue, 'scale(1, 1)', map);
  }

  ScaleEffect._internal(String hideValue, String showValue, Map<String, String> values) :
    super('-webkit-transform', hideValue, showValue, values);
}

class SpinEffect extends Css3TransitionEffect {
  SpinEffect() : super('-webkit-transform', 'perspective(600px) rotateX(90deg)', 'perspective(600px) rotateX(0deg)');
}

class DoorEffect extends Css3TransitionEffect {
  DoorEffect() : super('-webkit-transform', 'perspective(1000px) rotateY(90deg)', 'perspective(1000px) rotateY(0deg)',
      {'-webkit-transform-origin': '0% 50%'} );
}
