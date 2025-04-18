# encoding: utf-8
#

Picky::Tokenizer.default_indexing_with substitutes_characters_with: Picky::CharacterSubstituters::WestEuropean.new,
                                       removes_characters:          /[^äöüa-zA-Z0-9\s\/\-_:"&|]/i,
                                       stopwords:                   /\b(and|the|or|on|of|in|is|to|from|as|at|an)\b/i,
                                       splits_text_on:              /[\s\/\-_:"&\/]/,
                                       normalizes_words:            [[/\$(\w+)/i, '\1 dollars']],
                                       rejects_token_if:            lambda { |token| token.blank? || token == 'Amistad' },
                                       case_sensitive:              false

Picky::Tokenizer.default_searching_with substitutes_characters_with: Picky::CharacterSubstituters::WestEuropean.new,
                                        removes_characters:          /[^ïôåñëäöüa-zA-Z0-9\s\/\-_,&."~*:]/i,
                                        stopwords:                   /\b(and|the|or|on|of|in|is|to|from|as|at|an)\b/i,
                                        splits_text_on:              /[\s\/&\/]/,
                                        case_sensitive:              true,
                                        max_words:                   5