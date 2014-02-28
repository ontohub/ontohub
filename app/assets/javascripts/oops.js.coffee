$('.state').on 'click', 'a.pitfalls', (event) ->
  event.preventDefault()
  $('div.pitfalls').toggle()
  
$('.oops').popover(
  html: true,
  placement: 'top',
  trigger: 'hover',
  title: 'OOPS! Ontology Pitfall Scanner!',
  delay: {hide:800},
  content: '<a href="http://oeg-lia3.dia.fi.upm.es/oops/response.jsp">http://oeg-lia3.dia.fi.upm.es/oops/response.jsp</a>')
