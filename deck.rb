# deck.rb
# Chrisna Aing, 6/21/10
# Adding shuffle methods to the standard Array class.  And then representing a
# (blackjack) deck of cards, which usually consists of several normal decks of
# cards.

require "card"


class Array
  # Fisher-Yates shuffle; not included in Ruby 1.8.6.  Based upon pseudocode
  # found on Wikipedia.
  def shuffle!
    (length - 1).downto(1) do |i|
      j = rand(i + 1)
      self[j], self[i] = self[i], self[j]
    end
    return self
  end

  def shuffle
    dup.shuffle!
  end
end


class Deck
  @@normal_cards = 2..10
  @@face_cards = 11..13
  @@suits = %w{ clubs diamonds hearts spades }

  def initialize(decks)
    @cards = Array.new
    @deal_count = 0
    @index = 0

    # Deck manufacturing.
    decks.times do
      @@suits.each do |suit|
        @cards.push(Ace.new(suit))
        @@normal_cards.each do |rank|
          @cards.push(Card.new(rank, suit))
        end
        @@face_cards.each do |rank|
          @cards.push(FaceCard.new(rank, suit))
        end
      end
    end

    @cards.shuffle!
  end

  def to_s
    @cards.join(" ")
  end

  # Keeps track of how many cards are in play (for reshuffling).
  def start_deal
    @deal_count = 0
  end

  def next
    raise RangeError.new("@index shouldn't be >= @cards.length.") unless
      @index < @cards.length

    card = @cards[@index]
    @deal_count += 1
    @index += 1
    # If we are past the end of the array...
    if @index == @cards.length
      reshuffle!
    end
    return card
  end

  def reshuffle!
    # Moves all cards in play to the start and shuffles the remaining cards.
    # Does not care about index out-of-bounds errors.
    raise RangeError.new("@index shouldn't be less than @deal_count.") unless
      @index >= @deal_count

    in_play = @cards.slice!(@index - @deal_count, @deal_count)
    @cards.shuffle!
    @cards = in_play.concat(@cards)
    @index = @deal_count
  end
end
