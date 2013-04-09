    var ht = new $jit.Hypertree({  
      //id of the visualization container  
      injectInto: 'infovis',  
      //canvas width and height  
      width: 500,  
      height: 500,  
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
      onBeforeCompute: function(node){  
          //Log.write("centering");  
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
              style.color = "#ddd";  
      
          } else if(node._depth == 2){  
              style.fontSize = "0.7em";  
              style.color = "#555";  
      
          } else {  
              style.display = 'none';  
          }  
      
          var left = parseInt(style.left);  
          var w = domElement.offsetWidth;  
          style.left = (left - w / 2) + 'px';  
      },  
        
      onComplete: function(){  
          //Log.write("done");  
            
          //Build the right column relations list.  
          //This is done by collecting the information (stored in the data property)   
          //for all the nodes adjacent to the centered node.  
          var node = ht.graph.getClosestNodeToOrigin("current");  
          var html = "<h4>" + node.name + "</h4><b>Connections:</b>";  
          html += "<ul>";  
          node.eachAdjacency(function(adj){  
              var child = adj.nodeTo;  
              if (child.data) {  
                  var rel = (child.data.band == node.name) ? child.data.relation : node.data.relation;  
                  html += "<li>" + child.name + " " + "<div class=\"relation\">(relation: " + rel + ")</div></li>";  
              }  
          });  
          html += "</ul>";  
          $jit.id('inner-details').innerHTML = html;  
      }  
    });  
    
    
    var jitdata = {  
    "id": "347_0",  
    "name": "Nine Inch Nails",  
    "children": [{  
        "id": "235951_6",  
        "name": "Jeff Ward",  
        "data": {  
            "band": "Nine Inch Nails",  
            "relation": "member of band"  
        },  
        "children": [{  
            "id": "2382_7",  
            "name": "Ministry",  
            "data": {  
                "band": "Jeff Ward",  
                "relation": "member of band"  
            },  
            "children": []  
        }, {  
            "id": "2415_8",  
            "name": "Revolting Cocks",  
            "data": {  
                "band": "Jeff Ward",  
                "relation": "member of band"  
            },  
            "children": []  
        }, {  
            "id": "3963_9",  
            "name": "Pigface",  
            "data": {  
                "band": "Jeff Ward",  
                "relation": "member of band"  
            },  
            "children": []  
        }, {  
            "id": "7848_10",  
            "name": "Lard",  
            "data": {  
                "band": "Jeff Ward",  
                "relation": "member of band"  
            },  
            "children": []  
        }]  
    }, {  
        "id": "235950_11",  
        "name": "Richard Patrick",  
        "data": {  
            "band": "Nine Inch Nails",  
            "relation": "member of band"  
        },  
        "children": [{  
            "id": "1007_12",  
            "name": "Filter",  
            "data": {  
                "band": "Richard Patrick",  
                "relation": "member of band"  
            },  
            "children": []  
        }, {  
            "id": "327924_13",  
            "name": "Army of Anyone",  
            "data": {  
                "band": "Richard Patrick",  
                "relation": "member of band"  
            },  
            "children": []  
        }]  
    }, {  
        "id": "2396_14",  
        "name": "Trent Reznor",  
        "data": {  
            "band": "Nine Inch Nails",  
            "relation": "member of band"  
        },  
        "children": [{  
            "id": "3963_15",  
            "name": "Pigface",  
            "data": {  
                "band": "Trent Reznor",  
                "relation": "member of band"  
            },  
            "children": []  
        }, {  
            "id": "32247_16",  
            "name": "1000 Homo DJs",  
            "data": {  
                "band": "Trent Reznor",  
                "relation": "member of band"  
            },  
            "children": []  
        }, {  
            "id": "83761_17",  
            "name": "Option 30",  
            "data": {  
                "band": "Trent Reznor",  
                "relation": "member of band"  
            },  
            "children": []  
        }, {  
            "id": "133257_18",  
            "name": "Exotic Birds",  
            "data": {  
                "band": "Trent Reznor",  
                "relation": "member of band"  
            },  
            "children": []  
        }]  
    }, {  
        "id": "36352_19",  
        "name": "Chris Vrenna",  
        "data": {  
            "band": "Nine Inch Nails",  
            "relation": "member of band"  
        }
    }],  
    "data": []  
};

$(document).ready(function () {
  ht.loadJSON(graph);  
  //compute positions and plot.  
  ht.refresh(); 
  ht.controller.onComplete();
  }); 