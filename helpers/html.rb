helpers do
  def img(name)
    "<img src='images/#{name}' alt='#{name}' />"
  end

  def css(name)
    "<link rel='stylesheet' type='text/css' href='css/#{name}.css' />"
  end

  def js(name)
    "<script src='js/#{name}.js'></script>"
  end

  def scss(name)
    "<link rel='stylesheet' type='text/css' href='stylesheets/#{name}.css' />"
  end

  def coffee(name)
    "<script src='javascripts/#{name}.js'></script>"
  end
end
