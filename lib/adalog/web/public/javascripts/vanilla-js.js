adalog.vanillaJS = (function() {

  // Pure JS version of a jQuery-esque ready function.
  var docReady = function docReady(callback) {
    if("complete" === document.readyState || "interactive" === document.readyState) {
      callback();
    } else {
      document.addEventListener("DOMContentLoaded", callback);
    }
  };

  // Why does the phrase "array-like object" even exist?!
  var justGiveMeAnArrayJavaScriptYouPatheticExcuseForALanguage =
    function justGiveMeAnArrayJavaScriptYouPatheticExcuseForALanguage(arrayLike, force, defaultVal) {
    force       = !!force;
    defaultVal  = defaultVal || [];
    if(force) {
      try {
        return Array.prototype.slice.call(arrayLike);
      } catch(exc) {
        return defaultVal;
      }
    } else {
      return Array.prototype.slice.call(arrayLike);
    }
  };
  var convertArrayLike = justGiveMeAnArrayJavaScriptYouPatheticExcuseForALanguage;


  var eltHide = function eltHide(elt) {
    elt.style.display = 'none';
  };


  var eltShow = function eltShow(elt, display) {
    elt.style.display = display;
  };


  var eltShowBlock = function eltShowBlock(elt) {
    eltShow(elt, 'block');
  };


  var eltShowInline = function eltShowInline(elt) {
    eltShow(elt, 'inline');
  };


  var eltShowILBlock = function eltShowILBlock(elt) {
    eltShow(elt, 'inline-block');
  };


  var eltDisplayToggle = function eltDisplayToggle(elt, revealAsDisplay) {
    var currentDisplay = (window.getComputedStyle(elt, null) || elt.currentStyle).display;
    if('none' === currentDisplay) {
      elt.style.display = revealAsDisplay;
    } else {
      elt.style.display = 'none';
    }
  };


  var findSiblingByClassName = function findSiblingByClassName(elt, className) {
    return convertArrayLike(elt.parentNode.children).reduce(function(acc, child) {
      if(!!acc) {
        return acc;
      } else if(child.classList.contains(className)) {
        return child;
      } else {
        return false;
      }
    }, false);
  };


  var findAllSiblingsByClassName = function findAllSiblingsByClassName(elt, className) {
    return convertArrayLike(elt.parentNode.children).filter(function(child) {
      return child.classList.contains(className);
    });
  };


  return {
    // General purpose / not yet categorized
    'convertArrayLike': justGiveMeAnArrayJavaScriptYouPatheticExcuseForALanguage,
    'docReady'        : docReady,

    // Finders and element queries
    'findSiblingByClassName'      : findSiblingByClassName,
    'findAllSiblingsByClassName'  : findAllSiblingsByClassName,

    // Element visibility
    'eltHide'           : eltHide,
    'eltShow'           : eltShow,
    'eltShowBlock'      : eltShowBlock,
    'eltShowILBlock'    : eltShowILBlock,
    'eltShowInline'     : eltShowInline,
    'eltDisplayToggle'  : eltDisplayToggle
  };

})();
