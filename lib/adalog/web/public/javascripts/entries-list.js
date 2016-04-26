adalog.entriesList = (function(js) {

  var showButtonClass     = '-show-details';
  var hideButtonClass     = '-hide-details';
  var detailsContentClass = '-details-content';
  var toggleDetailsClass  = '-toggle-details';


  var init = function init() {
    js.docReady(function() {
      formatDetailsJSON();
      // initVisibilityButtons();
      initDetailsToggle();
    });
  };


  var formatDetailsJSON = function formatDetailsJSON() {
    var detailsElements = document.getElementsByClassName('-format-as-json');
    js.convertArrayLike(detailsElements).forEach(function(elt) {
      try {
        var contentsAsObj = JSON.parse(elt.textContent);
        elt.textContent   = JSON.stringify(contentsAsObj, null, 2);
      } catch(exc) {
        console.log("Failed to parse details of element that was expicitly flagged with '-format-as-json'.");
      }
    });
  };


  var initDetailsToggle = function initDetailsToggle() {
    var detailsToggles  = document.getElementsByClassName(toggleDetailsClass);
    var detailsRegions  = document.getElementsByClassName(detailsContentClass);

    js.convertArrayLike(detailsToggles).forEach(function(elt) {
      elt.addEventListener('click', function(evt) {
        var detailsContent = evt.currentTarget.getElementsByClassName(detailsContentClass)[0];
        js.eltDisplayToggle(detailsContent, 'block');
      })
    });

    js.convertArrayLike(detailsRegions).forEach(js.eltHide);
  };


  var initVisibilityButtons = function initVisibilityButtons() {
    var showButtons     = document.getElementsByClassName(showClass);
    var hideButtons     = document.getElementsByClassName(hideClass);
    var detailsRegions  = document.getElementsByClassName(detailsContentClass);
    var initiallyHidden = js.convertArrayLike(detailsRegions).concat(js.convertArrayLike(hideButtons));

    // Click events for show buttons show content, show a hide button and hide themselves.
    js.convertArrayLike(showButtons).forEach(function(elt) {
      elt.addEventListener('click', function(evt) {
        var hideSibling = js.findSiblingByClassName(evt.currentTarget, hideClass);
        var details     = js.findSiblingByClassName(evt.currentTarget, detailsContentClass);
        js.eltShowBlock(details);
        js.eltShowILBlock(hideSibling);
        js.eltHide(evt.currentTarget);
      });
    });

    // Click events for hide buttons hide content, show a show button and hide themselves.
    js.convertArrayLike(hideButtons).forEach(function(elt) {
      elt.addEventListener('click', function(evt) {
        var showSibling = js.findSiblingByClassName(evt.currentTarget, showClass);
        var details     = js.findSiblingByClassName(evt.currentTarget, detailsContentClass);
        js.eltHide(details);
        js.eltShowBlock(showSibling);
        js.eltHide(evt.currentTarget);
      });
    });

    initiallyHidden.forEach(js.eltHide);
  };


  return {
    'init': init
  };

})(adalog.vanillaJS);
