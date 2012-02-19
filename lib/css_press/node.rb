module CSSPool
  class Node
    def min_css
      accept Visitors::MinCSS.new
    end
  end
end
