# blackjack.rb
# Chrisna Aing, 6/21/10
# A simple game of blackjack.  Employs a basic command-line interface and
# (hopefully) runs on a vanilla installation of Ruby 1.8.6.
# The game ends when all players run out of money.

require "card"
require "deck"
require "hand"
require "player"

# Given a question and a range (min, max), returns user-inputted answer to said
# question; bugs the user until they enter a valid answer.
def receive_int(question, min, max)
  answer = receive_answer(question)
  while answer != answer.to_i.to_s or
    (answer == answer.to_i.to_s and (answer.to_i < min or answer.to_i > max))
    puts "Please enter an integer between #{min} and #{max}."
    answer = receive_answer(question)
  end
  return answer.to_i
end


class Game
  attr_accessor :players

  def initialize(players, decks)
    @players = Array.new
    @dealer = Dealer.new
    @deck = Deck.new(decks)

    players.times do |i|
      @players.push(Human.new("Player #{i + 1}"))
    end
  end

  def to_s
    @players.each do |player|
      puts player.to_s
    end
  end

  # Initialization of everything.
  def start_round
    @deck.start_deal
    @dealer.start_round
    @dealer.new_hand
    @players.each do |player|
      player.start_round
      player.new_hand
    end
  end

  def remove_bankrupt_players
    @players = @players.select {|player| player.money > 0}
    if @players.empty?
      puts
      puts "The game is over."
    end
  end

  def take_bets
    @players.each do |player|
      raise ArgumentError.new("Player shouldn't be bankrupt.") unless
        player.money > 0

      prompt = "#{player.name}, how much to bet ($1-$#{player.money})? "
      player.set_bet(player.first_hand, receive_int(prompt, 1, player.money))
    end
  end

  def deal_card(hand)
    # Helper function.
    hand.add(@deck.next)
  end

  def deal_first_cards
    # Dealer is dealt cards last.
    all_players = @players + [@dealer]
    2.times do
      all_players.each do |player|
        deal_card(player.first_hand)
      end
    end
  end

  def resolve_blackjacks
    if @dealer.first_hand.blackjack?
      puts "Dealer gets blackjack!"
      resolve_bets
    else
      @players.each do |player|
        if player.first_hand.blackjack?
          # Approximately a 3:2 payout to preserve integerness.
          profit = 3 * player.first_hand.bet / 2
          puts "#{player.name} wins $#{profit} with a blackjack!"
          player.money += player.first_hand.bet + profit
          player.first_hand.done = true
          player.first_hand.resolved = true
        end
      end
    end
  end

  def fill_hands
    # Players.
    @players.each do |player|
      hands_to_fill = player.hands.select {|hand| !hand.done}
      until hands_to_fill.empty?
        hands_to_fill.each do |hand|
          puts
          puts "#{player.name}, your hand is #{hand.to_s}.  The dealer is " +
            "showing #{@dealer.up_card}."

          # Offer to split and double down first if they are valid options.
          # To be valid options, there must be enough money and, in the case of
          # split, both cards must be equal.
          if player.money >= hand.bet
            if hand.cards[0].rank == hand.cards[1].rank
              player.split?(hand, @deck)
            end
            player.double_down?(hand, @deck)
          end

          # Then, offer to hit until they don't want to anymore or can't.
          # After this, the hand is completed.
          until hand.done
            player.hit?(hand, @deck)
          end

          # If the hand is busted, resolve immediately.
          if hand.bust?
            puts "#{player.name} busts with #{hand.to_s} (-$#{hand.bet})."
            hand.resolved = true
          end
        end
        hands_to_fill = player.hands.select {|hand| !hand.done}
      end
    end

    # Dealer.
    dealer_hand = @dealer.first_hand
    until dealer_hand.bust? or dealer_hand.done
      @dealer.hit?(dealer_hand, @deck)
    end
  end

  def resolve_bets
    puts
    puts "Time to resolve all live hands!"
    dealer_hand = @dealer.first_hand
    dealer_score = dealer_hand.to_i
    puts "The dealer's hand is #{dealer_hand.to_s}."
    # For each hand:
    @players.each do |player|
      player.hands.each do |hand|
        # Blackjack hands and busted hands are already resolved.
        if !hand.resolved
          bet = hand.bet
          # Now, we reward winners,
          if hand.to_i > dealer_score or dealer_hand.bust?
            puts "#{player.name} wins $#{bet} with #{hand.to_s}!"
            player.money += 2 * bet
          # square things with pushers,
          elsif hand.to_i == dealer_score
            puts "#{player.name} ties with #{hand.to_s}."
            player.money += bet
          # and leave losers alone.
          else
            puts "#{player.name} loses $#{bet} with #{hand.to_s}."
          end
        end
      end
    end
    puts "All live hands have been resolved."
  end

  def print_bankrupt_players
    bankrupt_players = @players.select {|player| player.money <= 0}
    if !bankrupt_players.empty?
      puts
      bankrupt_players.each do |player|
        puts "#{player.name} has $0 and must leave :(."
      end
    end
  end

  def play
    while true
      start_round
      remove_bankrupt_players
      break if @players.empty?

      puts
      puts "New round starting!"

      take_bets
      deal_first_cards
      resolve_blackjacks

      # If the dealer received a blackjack, the round is over.
      if !@dealer.first_hand.blackjack?
        fill_hands
        resolve_bets
      end

      print_bankrupt_players

    end
  end
end


puts "Welcome to blackjack!"
players = receive_int("How many players (1-7)? ", 1, 7)
decks = receive_int("How many decks will the shoe hold (1-8)? ", 1, 8)

blackjack_game = Game.new(players, decks)
blackjack_game.play
