window.jazzy = {'docset': false}
if (typeof window.dash != 'undefined') {
  document.documentElement.className += ' dash'
  window.jazzy.docset = true
}
if (navigator.userAgent.match(/xcode/i)) {
  document.documentElement.className += ' xcode'
  window.jazzy.docset = true
}

// On doc load, toggle the URL hash discussion if present and remove "last updated" from pages other than index.html
$(document).ready(function() {
  if (!window.jazzy.docset) {
    var linkToHash = $('a[href="' + window.location.hash +'"]');
    linkToHash.trigger("click");
  }
  
  // If the file path includes index.html, add last updated to prevent git file updates 
  var filePath = location.pathname;
  if (filePath.includes("index.html") || filePath.endsWith("/ios-sdk-swift/")) {
    const footerElement = document.getElementsByClassName("footer")[0];

    // Get the last updated date and format it
    let lastUpdatedTimeStamp = new Date(document.lastModified);
    const lastModifiedYear = lastUpdatedTimeStamp.getFullYear();
    const lastModifiedMonth = lastUpdatedTimeStamp.getMonth() + 1;
    const lastModifiedDate = lastUpdatedTimeStamp.getDate();
    lastUpdatedTimeStamp = lastModifiedYear + "-" + lastModifiedMonth + "-" + lastModifiedDate;

    // Append the formatted timestamp to the copyright text
    const lastUpdated = " (Last updated: " + lastUpdatedTimeStamp + ")";
    const dateSpan = document.createElement('span');
    dateSpan.innerHTML = lastUpdated;
    footerElement.childNodes[1].appendChild(dateSpan);
  }
});

// On token click, toggle its discussion and animate token.marginLeft
$(".token").click(function(event) {
  if (window.jazzy.docset) {
    return;
  }
  var link = $(this);
  var animationDuration = 300;
  $content = link.parent().parent().next();
  $content.slideToggle(animationDuration);

  // Keeps the document from jumping to the hash.
  var href = $(this).attr('href');
  if (history.pushState) {
    history.pushState({}, '', href);
  } else {
    location.hash = href;
  }
  event.preventDefault();
});

// Dumb down quotes within code blocks that delimit strings instead of quotations
// https://github.com/realm/jazzy/issues/714
$("code q").replaceWith(function () {
  return ["\"", $(this).contents(), "\""];
});
