module Ontology::FileExtensions
  extend ActiveSupport::Concern

  included do
    FILE_EXTENSIONS_DISTRIBUTED = %w[casl dol hascasl het]
    FILE_EXTENSIONS = FILE_EXTENSIONS_DISTRIBUTED + %w[owl hs exp maude elf hol isa thy prf omdoc hpf clf clif xml fcstd rdf gen_trm baf]
    
    FILE_EXTENSIONS_DISTRIBUTED.map! { |e| ".#{e}" }
    FILE_EXTENSIONS.map! { |e| ".#{e}" unless e.starts_with? '.' }
  end

end
