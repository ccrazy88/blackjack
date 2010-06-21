# card.rb
# Chrisna Aing, 6/21/10
# One superclass, two subclasses, three classes.  They represent cards!


class Card
  @@names = { 1 => "A", 2 => "2", 3 => "3", 4 => "4", 5 => "5", 6 => "6",
    7 => "7", 8 => "8", 9 => "9", 10 => "T", 11 => "J", 12 => "Q", 13 => "K" }
  @@suits = %w{ clubs diamonds hearts spades }

  attr_reader :rank

  def initialize(rank, suit)
    raise ArgumentError.new("Rank isn't between 1 and 13.") unless
      rank >= 1 and rank <= 13
    raise ArgumentError.new("Suit isn't #{@@suits.join(' or ')}.") unless
      @@suits.include?(suit)

    @rank = rank
    @suit = suit
  end

  def to_s
    "#{@@names[@rank]}#{@suit[0..0]}"
  end

  def hard_value
    return rank
  end

  def soft_value
    return rank
  end
end


class FaceCard < Card
  def initialize(rank, suit)
    raise ArgumentError.new("Rank isn't between 11 and 13.") unless
      rank >= 11 and rank <= 13

    super(rank, suit)
  end

  def hard_value
    return 10
  end

  def soft_value
    return 10
  end
end


class Ace < Card
  def initialize(suit)
    super(1, suit)
  end
  
  def hard_value
    return 1
  end

  def soft_value
    return 11
  end
end
