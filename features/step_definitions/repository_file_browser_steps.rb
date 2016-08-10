When(/^I visit the file browser of the ontology's repository$/i) do
  visit repository_tree_path(@ontology.repository)
end

Then(/^I should see the ontology's file$/i) do
  file_cell_selector = 'table.file-table td.name'
  expect(page).to have_selector(file_cell_selector, count: 1)
  expect(find(file_cell_selector).
    has_link?(@ontology.path, polymorphic_path(@ontology))).
    to be(true)
end

Then(/^I should see the ontlogy next to the ontology's file$/i) do
  ontology_cell_selector = 'table.file-table td.ontology ul.ontology-list'
  expect(page).to have_selector(ontology_cell_selector, count: 1)
  expect(find(ontology_cell_selector).
    has_link?(@ontology.name, polymorphic_path(@ontology))).
    to be(true)
end

Then(/^I should see no other ontologies next to the ontology's file$/i) do
  ontology_cell_selector = 'table.file-table td.ontology ul.ontology-list'
  expect(find(ontology_cell_selector)).
    to have_selector('li', count: 1 + @ontology.children.count)
end

Then(/^I should see the ontlogy and its children next to the ontology's file$/i) do
  ontology_cell_selector = 'table.file-table td.ontology ul.ontology-list'
  expect(page).to have_selector(ontology_cell_selector, count: 1)
  expect(find(ontology_cell_selector).
    has_link?(@ontology.name, polymorphic_path(@ontology))).
    to be(true)
  @ontology.children.each do |child|
    expect(find(ontology_cell_selector).
      has_link?(child.name, polymorphic_path(child))).
      to be(true)
  end
end
