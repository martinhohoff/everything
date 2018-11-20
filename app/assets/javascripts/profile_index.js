document.addEventListener('DOMContentLoaded', function() {

function l(x) {
  return console.log(x)
}

var percentColors = [
    { pct: 0.0, color: { r: 0xff, g: 0x00, b: 0 } },
    { pct: 0.6, color: { r: 0xff, g: 0xff, b: 0 } },
    { pct: 1.0, color: { r: 0x00, g: 0xff, b: 0 } } ];

var getColorForPercentage = function(pct) {
    for (var i = 1; i < percentColors.length - 1; i++) {
        if (pct <= percentColors[i].pct) {
            break;
        }
    }
    var lower = percentColors[i - 1];
    var upper = percentColors[i];
    var range = upper.pct - lower.pct;
    var rangePct = (pct - lower.pct) / range;
    var pctLower = 1 - rangePct;
    var pctUpper = rangePct;
    var color = {
        r: Math.floor(lower.color.r * pctLower + upper.color.r * pctUpper),
        g: Math.floor(lower.color.g * pctLower + upper.color.g * pctUpper),
        b: Math.floor(lower.color.b * pctLower + upper.color.b * pctUpper)
    };
    return 'rgb(' + [color.r, color.g, color.b].join(',') + ')';
}


allPercentages = document.getElementsByClassName("profile-table-relevance")

relevancePercentageCollection = []

allPercentageValues = document.getElementsByClassName("relevance-pct")
Array.prototype.forEach.call(allPercentageValues, pct => {
  relevancePercentageCollection.push(parseInt(pct.innerHTML,10)/100)
});

Array.prototype.forEach.call(allPercentages, pct => {
  pct.style.color = getColorForPercentage(relevancePercentageCollection[0])
  relevancePercentageCollection.shift()
});

});
