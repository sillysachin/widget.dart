part of effects;

// TODO: ponder SwapResult enum: failed due to element states, swallowed by a
//       swap that started before the requested one finished, etc

/**
 * [effect] is used as the [hideEffect] unless [hideEffect] is provided.
 */
class Swapper {

  static Future<bool> swap(Element host, Element child,
      {ShowHideEffect effect, int duration, EffectTiming effectTiming, ShowHideEffect hideEffect}) {

    assert(host != null);
    assert(child != null);

    if(?effect && !?hideEffect) {
      hideEffect = effect;
    }

    if(child.parent != host) {
      // only children of the provided host are supported
      return new Future<bool>.immediate(false);
    }

    // ensure at most one child of the host is visible before beginning
    return _ensureOneShown(host)
        .chain((bool shouldContinue) {
          if(!shouldContinue) {
            return new Future.immediate(false);
          }

          final futures = host.children.map((Element e) {
            var action = ShowHideAction.HIDE;
            var zIndex = 1;
            var theEffect = hideEffect;

            if(e == child) {
              action = ShowHideAction.SHOW;
              zIndex = 2;
              theEffect = effect;
            }

            e.style.zIndex = zIndex.toString();
            return ShowHide.begin(action, e, effect: theEffect, duration: duration, effectTiming: effectTiming)
                .transform((bool done) {
                  e.style.zIndex = '';
                  return done;
                });
          });

          return Futures.wait(futures)
              .transform((List<bool> results) => results.every((a) => a));
        });
  }

  static Future<bool> _ensureOneShown(Element host) {
    assert(host != null);
    if(host.children.length == 0) {
      return new Future.immediate(false);
    } else if(host.children.length == 1) {
      final child = host.children[0];
      return ShowHide.show(child);
    }
    // NOTE: there is *no* way, with async computerStyle APis, to do this
    // in a way that ensures the host child collection doesn't change while
    // we're figuring things out. FYI.

    // 1 - get states of all children
    final futures = host.children
        .map(ShowHide.getState);

    return Futures.wait(futures)
        .chain((List<ShowHideState> states) {
          // paranoid sanity check that at lesat the count of items
          // before and after haven't changed
          assert(states.length == host.children.length);

          // See how many of the items are actually shown
          final showIndicies = new List<int>();
          for(int i=0; i<states.length;i++) {
            if(states[i].isShow) {
              showIndicies.add(i);
            }
          }

          if(showIndicies.length == 0) {
            // show last item -> likely the visible one
            return ShowHide.show(host.children[host.children.length-1]);
          } else if(showIndicies.length > 1) {
            // if more than one is shown, hide all but the last one
            final toHide = showIndicies
                .getRange(0, showIndicies.length - 1)
                .map((int index) => host.children[index]);
            return _hideAll(toHide);
          } else {
            assert(showIndicies.length == 1);
            // only one is shown...so...
            return new Future.immediate(true);
          }
        });
  }

  static Future<bool> _hideAll(List<Element> elements) {
    final futures = elements.map((Element e) => ShowHide.hide(e));
    return Futures.wait(futures)
        .transform((List<bool> successValues) => successValues.every((v) => v));
  }
}