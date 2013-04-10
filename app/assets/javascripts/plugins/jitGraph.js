var ht = new $jit.Hypertree({  
      //id of the visualization container  
      injectInto: 'infovis',  
      //canvas width and height  
      width: 500,  
      height: 350,  
      //Change node and edge styles such as  
      //color, width and dimensions.  
      Node: {  
          dim: 9,  
          color: "#f00"  
      },  
      Edge: {  
          lineWidth: 2,  
          color: "#088"  
      },  
      //Attach event handlers and add text to the  
      //labels. This method is only triggered on label  
      //creation  
      onCreateLabel: function(domElement, node){  
          domElement.innerHTML = node.name;  
          $jit.util.addEvent(domElement, 'click', function () {  
              ht.onClick(node.id, {  
                  onComplete: function() {  
                      ht.controller.onComplete();  
                  }  
              });  
          });  
      },  
      //Change node styles when labels are placed  
      //or moved.  
      onPlaceLabel: function(domElement, node){  
          var style = domElement.style;  
          style.display = '';  
          style.cursor = 'pointer';  
          if (node._depth <= 1) {  
              style.fontSize = "0.8em";  
              style.color = "#555";  
      
          } else if(node._depth == 2){  
              style.fontSize = "0.7em";  
              style.color = "#999";  
      
          } else {  
              style.display = 'none';  
          }  
      
          var left = parseInt(style.left);  
          var w = domElement.offsetWidth;  
          style.left = (left - w / 2) + 'px';  
      },  
    });  

$(document).ready(function () {
  ht.loadJSON(graph);  
  //compute positions and plot.  
  ht.refresh(); 
  ht.controller.onComplete();
  }); 