module Catalog
  class CreateIcon
    attr_reader :icon

    def initialize(args)
      @extension = args.delete(:filename).split(".").last
      @content = args.delete(:content)
      @params = args
    end

    def process
      image = Image.new(:extension => @extension, :content => @content)
      image_id = Catalog::DuplicateImage.new(image).process.image_id

      @icon = Icon.create!(@params.merge(:image_id => image_id))

      self
    end
  end
end
