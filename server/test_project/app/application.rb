# encoding: utf-8
#
class BookSearch < Application
  
  # indexes :partial => Cacher::Partial::Subtoken.new, :similarity => Cacher::Similarity::None.new do |index|
  #   
  #   index.illegal(/[',\(\)#:!@]/)
  #   index.contract(/mr\.\s*|mister\s*/i, 'mr')
  #   index.stopwords(/\b(and|the|or|on)\b/)
  #   index.split_on(/[\s\/\-\"\&\.]/)
  #   index.illegal_after_normalizing(/[\.]/)
  #   
  #   few_similarities = Similarity::DoubleLevenshtone.new(3)
  #   similar_title = field :title,  :similarity => few_similarities,
  #                                  :qualifiers => [:t, :title, :titre]
  #   author        = field :author, :qualifiers => [:a, :author, :auteur]
  #   year          = field :year,   :partial    => Partial::None.new,
  #                                  :qualifiers => [:y, :year, :annee]
  #   index.add :main,
  #         "SELECT title, author, year FROM books",
  #         similar_title,
  #         author,
  #         year,
  #         :heuristics => Query::Heuristics.new([:title,  :author] => 5,
  #                                              [:author, :year]   => 2)
  #   
  #   index.add :isbn,
  #         "SELECT isbn FROM books",
  #         field(:isbn, :qualifiers => [:i, :isbn])
  # end
  
  queries do |configure|
    configure.maximum_tokens 5
    configure.illegal_characters(/[\(\)\']/)
    configure.contract_expressions(/mr\.\s*|mister\s*/i, 'mr')
    configure.stopwords(/\b(and|the|or|on)/i)
    configure.split_text_on(/[\s\/\-\,\&]+/)
    configure.normalize_words([
      [/Deoxyribonucleic Acid/i, 'DNA']
    ])
    configure.illegal_characters_after(/[\.]/)
    
    configure.route '^/books/full', Query::Full.new(Indexes[:main], Indexes[:isbn])
    configure.route '^/books/live', Query::Live.new(Indexes[:main], Indexes[:isbn])
    
    configure.route '^/isbn/full',  Query::Full.new(Indexes[:isbn])
    
    configure.root 200
  end
  
end