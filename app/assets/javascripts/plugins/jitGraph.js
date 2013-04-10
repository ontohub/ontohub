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
      onComplete: function(){	        
	      //Build the right column relations list.  
	      //This is done by collecting the information (stored in the data property)   
	      //for all the nodes adjacent to the centered node.  
	      var node = ht.graph.getClosestNodeToOrigin("current");  
	      var html = "<h4>" + node.name + "</h4><b>Connections:</b>";  
	      html += "<ul>";  
	      node.eachAdjacency(function(adj){  
	          var child = adj.nodeTo;  
	          if (child.data) {  
	              var url = child.data.url;  
	              html += "<li>" + child.name + " " + "<div class=\"relation\">(relation: " + url + ")</div></li>";  
	          }  
	      });  
	      html += "</ul>";  
	      $jit.id('infoviscontext').innerHTML = html;  
  	  	}  
    });  

$(document).ready(function () {
  ht.loadJSON(graph);  
  //compute positions and plot.  
  ht.refresh(); 
  ht.controller.onComplete();
  }); 