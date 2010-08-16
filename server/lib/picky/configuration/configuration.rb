module Configuration

  def self.indexes *types
    Indexes.new(*types).save
  end
  def self.type name, *fields
    Type.new name, *fields
  end
  def self.field name, options = {}
    Field.new name, options
  end

end