$ ->
  $.jstree._themes = "/assets/jstree-themes/"
  $(".selector").jstree
    plugins: [
      "search"
      "themes"
      "html_data"
      "checkbox"
      "sort"
      "ui"
    ]
    themes:
      theme: "classic"
      icons: false
    checkbox:
      two_state: true
      real_checkboxes: true
      real_checkboxes_names: (n) ->
        [
          "category_ids[" + n[0].id + "]"
          1
        ]

$ ->
  container = $(".selector")
  container.bind "loaded.jstree", (event, data) ->
    $.getJSON container.data("uri"), (data) ->
      $.each data, ->
        container.jstree "check_node", "#" + @id

$ ->
  $("#tree").jstree
    plugins: [
      "themes"
      "html_data"
      "sort"
      "ui"
    ]
    themes:
      theme: "classic"
      icons: false
      dots: false

$("#tree").delegate "a", "click", (e) ->
  document.location.href = this
