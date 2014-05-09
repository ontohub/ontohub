class PopulateDatabaseWithOntologyFileExtensions < ActiveRecord::Migration
  def change
    file_extensions_distributed = %w[casl dol hascasl het]
    file_extensions_single = %w[owl obo hs exp maude elf hol isa thy prf omdoc hpf clf clif xml fcstd rdf xmi qvt tptp gen_trm baf]

    file_extensions_distributed.map! { |e| ".#{e}" }
    file_extensions_single.map! { |e| ".#{e}" }

    file_extensions_distributed.each do |ext|
      ActiveRecord::Base.connection.execute(
        "INSERT INTO ontology_file_extensions (extension, distributed) VALUES ('#{ext}', 'true')")
    end
    file_extensions_single.each do |ext|
      ActiveRecord::Base.connection.execute(
        "INSERT INTO ontology_file_extensions (extension, distributed) VALUES ('#{ext}', 'false')")
    end
  end
end
