module Output
  # Colorize module
  module Color

    STYLES = { :normal => 0, :bold => 1, :underscore => 4, :blink => 5, :inverse => 7, :concealed => 8 }
    COLORS = { :black  => 0, :blue => 4, :green => 2, :cyan => 6, :red => 1, :purple => 5, :brown => 3, :white => 7 }

    # Colorize text
    # <tt>text</tt> The text to colorize
    # Options
    #  * <tt>:background</tt> The background color to paint. Defined in Color::COLORS
    #  * <tt>:color</tt> The foreground color to paint. Defined in Color::COLORS
    #  * <tt>:on</tt> Alias for :background
    #  * <tt>:style</tt> Font style, defined in Color::STYLES
    #
    # Returns ASCII colored string
    def self.colorize(text, *options)

      font_style       = ''
      foreground_color = '0'
      background_color = ''

      options.each do |option|
        if option.kind_of?(Symbol)
          foreground_color = "3#{COLORS[option]}" if COLORS.include?(option)
          font_style       = "#{STYLES[option]};" if STYLES.include?(option)
        elsif option.kind_of?(Hash)
          option.each do |key, value|
            case key
            when :color;      foreground_color = "3#{COLORS[value]}"  if COLORS.include?(value)
            when :background; background_color = "4#{COLORS[value]};" if COLORS.include?(value)
            when :on;         background_color = "4#{COLORS[value]};" if COLORS.include?(value)
            when :style;      font_style       = "#{STYLES[value]};"  if STYLES.include?(value)
            end
          end
        end
      end
      return "\e[#{background_color}#{font_style}#{foreground_color}m#{text}\e[0m"
    end

  end
end
