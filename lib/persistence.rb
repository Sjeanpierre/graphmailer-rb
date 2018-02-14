require 'pstore'
module PERSISTENCE
  class Creds
    def initialize
      @DB = PStore.new('cred.db')
    end

    def get(name)
      @DB.transaction do
        @DB.fetch(name.to_sym, nil)
      end
    end

    def set (name,value)
      @DB.transaction do
        @DB[name.to_sym] = value.to_hash
      end
    end


  end

end