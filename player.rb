# player.rb
# Chrisna Aing, 6/21/10
# An interactive blackjack player.

require "hand"

def receive_answer(question)
  print question
  gets.chomp
end


class Player
  attr_reader :hands, :name

  def initialize(name)
    @name = name
    @hands = Array.new
  end

  def start_round
    @hands = Array.new
  end

  def new_hand
    hand = Hand.new
    @hands.push(hand)
  end

  def first_hand
    @hands[0]
  end

  def hit(hand, deck)
    raise ArgumentError.new("This hand has already busted.") unless !hand.bust?
  end
end


class Human < Player
  attr_accessor :money

  def initialize(name)
    super(name)
    @money = 1000
  end

  def to_s
    s = "#{@name}\n  Money: $#{@money}\n  Hands:\n"
    @hands.each do |hand|
      s.concat("    #{hand.to_s}\n")
    end
    s.chomp!
    return s
  end

  def set_bet(hand, bet)
    raise ArgumentError.new("The bet's impossibly large.") unless bet <= @money

    @money -= bet
    hand.bet = bet
  end

  def hit(hand, deck)
    super
    question = "#{@name}, would you like to (h)it or (s)tand? "
    response = receive_answer(question)[0..0]
    until response == 'h' or response == 's'
      puts "Please enter 'h' (hit) or 's' (stand)."
      response = receive_answer(question)[0..0]
    end

    if response == 'h'
      hand.add(deck.next)
      return true
    end
    return false
  end

  def double_down(hand, deck)
    raise ArgumentError.new("Inappropriate hand.") unless
      hand.cards.length == 2
    raise ArgumentError.new("Not enough money.") unless hand.bet <= @money

    question = "#{@name}, would you like to double down (y/n)? "
    response = receive_answer(question)[0..0]
    until response == 'y' or response == 'n'
      puts "Please enter 'y' (yes) or 'n' (no)."
      response = receive_answer(question)[0..0]
    end

    if response == 'y'
      @money -= hand.bet
      hand.bet += hand.bet
      hand.add(deck.next)
      return true
    end
    return false
  end

  def split(hand, deck)
    raise ArgumentError.new("Inappropriate hand.") unless
      hand.cards.length == 2 and hand.cards[0].rank == hand.cards[1].rank
    raise ArgumentError.new("Not enough money.") unless hand.bet <= @money

    puts "#{@name}, would you like to split (y/n)? "
    response = gets.chomp[0..0]
    if response == 'y'
      # Doesn't matter which.
      card = hand.remove!(0)
      @money -= hand.bet
      new_hand = Hand.new(hand.bet)
      new_hand.add(card)

      hand.add(deck.next)
      new_hand.add(deck.next)

      @hands.push(new_hand)
      return new_hand
    end
    return nil
  end
end


class Dealer < Player
  def initialize
    super("Dealer")
  end

  def hit(hand, deck)
    super
    # Stands on all 17s.
    return true if hand.to_i < 17
    return false
  end
end
