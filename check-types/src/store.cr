module Store
  STORE = Hash(String, String).new

  def Store.get(name) : String
    STORE[name]
  end

  def Store.set(name, value) : Nil
    STORE[name] = value
  end
end
