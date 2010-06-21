# hand.rb
# Chrisna Aing, 6/21/10
# A blackjack hand.

require "card"


class Hand
  attr_accessor :bet, :cards, :done, :resolved

  # An empty hand.
  def initialize
    @bet = nil
    @cards = Array.new
    @done = false
    @resolved = false
  end

  def to_s
    "#{@cards.join(" ")} -> #{to_i}"
  end

  def to_i
    if soft_total <= 21
      return soft_total
    else
      return hard_total
    end
  end

  def add(card)
    raise ArgumentError.new("Cards only, please.") unless card.kind_of?(Card)

    @cards.push(card)
  end

  def empty?
    @cards.empty?
  end

  def remove!(index)
    @cards.slice!(index)
  end

  def size
    return @cards.length
  end

  def blackjack?
    return true if size == 2 and to_i == 21
    return false
  end

  def bust?
    return true if to_i > 21
    return false
  end

  def hard_total
    total = 0
    @cards.each do |card|
      total += card.hard_value
    end
    return total
  end

  def soft_total
    total = 0
    ace_found = false
    # Only one ace contributes its soft value to the hand.
    @cards.each do |card|
      if card.kind_of?(Ace)
        if !ace_found
          total += card.soft_value
          ace_found = true
        else
          total += card.hard_value
        end
      else
        total += card.soft_value
      end
    end
    return total
  end
end
