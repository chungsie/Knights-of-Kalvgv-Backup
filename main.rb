#This is for a working demo
#NPC deck
        # for i in (0..@size_x)
        #     for leng in (0..@size_y)
        #          if (i > 0 && i < @size_x) #&& (leng > 0 && leng < @size_y) #&& (i > 0 && i < @size_x)
        #         #     @walls_gr[i,leng] = "#"
        #         # elsif (leng != 0 && leng != @size_y) && (i == 0 || i == @size_x)
        #         #     @walls_gr[i,leng] = "#"
        #         # else
        #              @walls_gr[i,leng] = "@"
        #          else
        #             @walls_gr[i,leng] = "#"
        #          end
        #     end
        # end   
class Npc
    attr :x, :y, :race, :klass, :text, :book, :page, :chapter, :races, :trigger, :stats, :skills, :default_weapon, :base_dc, :initiate, :names, :choice, :id_t, :b_races, :building
    attr :red, :health
    def initialize
        @races  = { elf: 1, dwarf: 3, goblin: 4, troll: 5}
        @b_races = { elf: 0, dwarf: 1, goblin: 2, troll: 3 }
        @building = 0
        puts @stats
        @x      = rand 1280
        @y      = rand 720
        @race   = @races.keys.sample
        @red = 0
        if @race == :elf
            init_elf()
        end
        if @race == :dwarf
            init_dwarf()
        end
        if @race == :goblin
            init_goblin()
        end
        if @race == :troll
            init_troll()
        end
        puts @building
        puts @race
        puts @stats, @skills
        @klass  = [:wizard, :cleric].sample
        @skills = { thievery: 0, stealth: 0, healing: 0, mend: 0, lockpicking: 0, intimidate: 0, jump: 0, dash: 0 }
        @default_weapon = 0
        @image = ""
        @text = ""
        @id_t = 0
        @page = 0
        @chapter = 0
        @choice = ""
        @trigger = false
        @book= Array.new(100) { Array.new(100, 0) }
        @initiate = false
        @names = "NPC"
        @health = 8
        @book = [["Welcome","Tell me about yourself"],
        ["So you are an Elf","Magic folk are wonderful"],
        ["So you are a Dwarf","Must miss the old mines"],["Well this is the setting","Press 1 to draw a card from the NPC deck...","Now kill it"],
        ["Well done. You can convert or kill an enemy to clear a room.", "Clearing a room makes it apart of your domain.", "After all, you are the sovereign temporarily.","Go to the light token in the center.","It will give you a tunnel card."]]
    end

    def init_elf
        @stats = { melee: 1, ranged: 3, touch: -1, ranged_magic: 5 }
        @skills = { thievery: -1, stealth: 5, healing: -1, mend: 5, lockpicking: 1, intimidate: 1, jump: 3, dash: 3 }
        @building = @b_races[:elf]
        @base_dc = 3
    end

    def init_dwarf
        @stats = { melee: 3, ranged: 1, touch: 5, ranged_magic: -1 }
        @skills = { thievery: 5, stealth: -1, healing: 5, mend: -1, lockpicking: 3, intimidate: 3, jump: 1, dash: 1 }
        @building = @b_races[:dwarf]
        @base_dc = 4
    end

    def init_goblin
        @stats = { melee: 4, ranged: 2, touch: -1, ranged_magic: 3 }
        @skills = { thievery: -1, stealth: 3, healing: -1, mend: 3, lockpicking: 4, intimidate: 4, jump: 2, dash: 2 }
        @building = @b_races[:goblin]
        @base_dc = 2
    end

    def init_troll
        @stats = { melee: 5, ranged: -1, touch: 3, ranged_magic: -1 }
        @skills = { thievery: 3, stealth: -1, healing: 3, mend: -1, lockpicking: 5, intimidate: 5, jump: -1, dash: -1 }
        @building = @b_races[:troll]
        @base_dc = 5
    end

    def draw
        [@x, @y, @text]
    end

    def turn_page
        @trigger = true
        if @chapter == 0 && @page > 1
            @page -= 1
            @trigger = false
        end
        if (@chapter == 1 || @chapter == 2) && @page > 1
            @page = 0
            @chapter = 3
            @trigger = false
        end
        if @page > 1 && $game.rooms[$game.current_room].npc_count != 0 && (@chapter == 3)
            @page -= 1
            @trigger = false
        end
        if $game.rooms[$game.current_room].habit_count > 0 && @chapter == 3
            @chapter = 4
            @page = 0
            @trigger = false
        end
        if @chapter == 4 && @page >= 5
            @page -= 1
            @trigger = false
        end
        @page += 1 if $game.rooms[$game.current_room].in_dialogue && @trigger
        @text = @book[@chapter][@page]
        puts @page.to_s + "page", @chapter.to_s + "chapter"
    end
end

class Hero
    attr :race, :klass, :text, :x, :y, :races, :stats, :skills, :default_weapon, :select_target, :target, :base_dc, :names, :line_of_sight, :red
    attr :encumbrance, :carry_max, :health, :kills, :conversion, :default_weapon_stats, :max_stats, :max_health

    def initialize
        @text = ""
        @races = { elf: 0, dwarf: 2, noone: 8}
        @race = :noone
        @stats = { melee: 0, ranged: 0, touch: 0, ranged_magic: 0 }
        @max_stats = { melee: 0, ranged: 0, touch: 0, ranged_magic: 0 }
        @skills = { thievery: 0, stealth: 0, healing: 0, mend: 0, lockpicking: 0, intimidate: 0, jump: 0, dash: 0 }
        @default_weapon = 0
        @select_target = false
        @target = nil
        @base_dc = 5
        @red = 0
        @names = "HERO"
        @line_of_sight = 3
        @carry_max = 0
        @encumbrance = 0
        @health = 8
        @max_health = @health
        @kills = 0
        @conversion = 0
        @ret = ""
        @detection = 0
        @default_weapon_stats = 1
        @klass = :noone
    end

    def init_elf
        @stats = { melee: 1, ranged: 3, touch: -1, ranged_magic: 5 }
        @max_stats = { melee: 1, ranged: 3, touch: -1, ranged_magic: 5 }
        @skills = { thievery: -1, stealth: 5, healing: -1, mend: 5, lockpicking: 1, intimidate: 1, jump: 3, dash: 3 }
        puts @stats, @skills
        @line_of_sight = 5
        @carry_max = 4
        @detection = 4
    end

    def init_dwarf
        @stats = { melee: 3, ranged: 1, touch: 5, ranged_magic: -1 }
        @max_stats = { melee: 3, ranged: 1, touch: 5, ranged_magic: -1 }
        @skills = { thievery: 5, stealth: -1, healing: 5, mend: -1, lockpicking: 3, intimidate: 3, jump: 1, dash: 1 }
        puts @stats, @skills
        @line_of_sight = 5
        @carry_max = 4
        @detection = 4
    end

    def klass_cleric
        if @race == :dwarf
            @stats = { melee: 3, ranged: 1, touch: 7, ranged_magic: -1 }
            @max_stats = { melee: 3, ranged: 1, touch: 7, ranged_magic: -1 }
            @skills = { thievery: 7, stealth: -1, healing: 7, mend: -1, lockpicking: 3, intimidate: 3, jump: 1, dash: 1 }
        end
        if @race == :elf
            @stats = { melee: 1, ranged: 3, touch: 1, ranged_magic: 5 }
            @max_stats = { melee: 1, ranged: 3, touch: 1, ranged_magic: 5 }
            @skills = { thievery: 1, stealth: 5, healing: 1, mend: 5, lockpicking: 1, intimidate: 1, jump: 3, dash: 3 }
        end
        @health += 2
    end 

    def flair target
        @check = rand(5) + 1 + @detection
        puts @check
        @ret = "You rolled a " + @check.to_s + " to detect. "
        @ret += " It is " + challenge_m(target).to_s + " on melee," if @check > 7
        @ret += " " + target.race.to_s if @check > 5
        @ret += " " + target.health.to_s + " HP" if @check > 8
        @ret += " unknown. Try again after moving" if @check < 5
        return @ret
    end

    def challenge_m target
        return "hard" if target.stats[:melee] > @stats[:melee]
        return "easy" if target.stats[:melee] < @stats[:melee]
        return "equal"
    end
end

class Weapon_Cards 
    attr :deck, :icon, :x, :y, :encumbrance_chart, :names, :stats

    def initialize
        @deck = { unarmed: 0, dagger: 1 }
        @icon = { nothing: 0, dagger: 1 }
        @encumbrance_chart = { unarmed: 0, dagger: 1 }
        @x = 0
        @y = 0
        @stats = [1,2]
    end
end

class Objects
    attr :text, :x, :y

    def initialize
        @text = ""
        @x = 1
        @y = 1
    end

end

class Habitation
    attr_accessor :image, :x, :y, :types

    def initialize
        @types = { elf: 0, dwarf: 1, goblin: 2, troll: 3 }
        @image = @types[:elf]
        @x = 0
        @y = 0
    end
end 

class Room 
    attr_gtk
    attr :size_w, :size_h, :trigger, :room_number, :object_count, :npc_deck_drawn, :npc_count, :tile_w, :tile_h, :tiles, :in_dialogue
    attr :damage_base, :damage_total, :dc, :reduction, :habitations, :habit_count, :population, :loot, :loot_count, :hero, :guide, :domain

    def initialize
        #@npcs = (50 + rand(50)).map { Npc.new }
        @size_w = [8,10,12,14,16].sample
        @size_h = [8,10,12,14,16].sample
        @samples = { wall: 6, floors: 9, hero_place: 0, guide_p: 7, elf_statue: 10, dwarf_statue: 11, token: 12 }
        @tiles = { wall: 0, floors: 1, water: 2 }
        @room_size = @size_w + @size_h
        @pos_room_x = 1280/2
        @pos_room_y = (700/2) + 200
        @room_number = 0
        @npc_count = -1
        @object_count = 0
        @habitations = []
        @tile_w = 32
        @tile_h = 32
        @loot = []
        @loot_count = 0
        @domain = false
        @choice = "nothing"
        @in_dialogue = false
        @population = { elf: 0, dwarf: 0, goblin: 0, troll: 0 }
        @habit_count = 0
        @characters = Array.new(@size_w) { Array.new(@size_h, 9) }
        puts @room_size.to_s + " size"
        @room = Array.new(@size_w) { Array.new(@size_h, 0) }
        for i in (0...@size_w) 
            for j in (0...@size_h)
                if (i == 0 || i == @size_w - 1 ) || (j == 0 || j == @size_h - 1 )
                    @room[i][j] = @tiles[:wall]
                    @characters[i][j] = @samples[:wall]
                else
                    @room[i][j] = @tiles[:floors]
                    if @room_number == 0 && @npc_count == -1 && rand(10) < 4
                        @guide = Npc.new
                        @guide.x = i
                        @guide.y = j
                        @guide.names = "GUIDE"
                        @characters[i][j] = @samples[:guide_p]
                        @npc_count += 1
                    else
                        @characters[i][j] = @samples[:floors]
                    end
                end
            end
        end
        @npc_deck_drawn = [@guide]
        puts @room
        @hero = Hero.new
        @hero.x = @size_w/2
        @hero.y = @size_h/2
        @characters[@size_w/2][@size_h/2] = @hero.races[@hero.race]
        @trigger = false
    end

    def world a, b
        {
            x: @pos_room_x + (a * @tile_w),
            y: @pos_room_y - (b * @tile_h) - @tile_h,
            w: @tile_w,
            h: @tile_h,
            path: 'sprites/world.png',
            tile_x: @room[a][b] * (@tile_w / 2),#@tiles[@room[a][b]],#*@tile_w,
            tile_y: 0,
            tile_w: @tile_w / 2,
            tile_h: @tile_h / 2
        }
    end

    def get_name number
        @names = ["Fist","Dagger"]
        return @names[number]
    end

    def character_render a, b
        {
            x: @pos_room_x + (a * @tile_w),
            y: @pos_room_y - (b * @tile_h) - @tile_h,
            w: @tile_w,
            h: @tile_h,
            path: 'sprites/sprites.png',
            tile_x: @characters[a][b] * (@tile_w / 2),#@tiles[@room[a][b]],#*@tile_w,
            tile_y: 0,
            tile_w: @tile_w / 2,
            tile_h: @tile_h / 2
        }
    end

    def ui_left_bg
        {
            x: 0,
            y: 20,
            w: 300,
            h: 700,
            path: 'sprites/ui-left-bg.png'
        }
    end

    def ui_top_bg
        {
            x: 300,
            y: 520,
            w: 900,
            h: 200,
            path: 'sprites/ui-top-bg.png'
        }
    end

    def ui_button_atk
       {
           x: 100,
           y: 500,
           w: 100,
           h: 50,
           path: 'sprites/buttons.png',
           tile_x: 0,
           tile_y: 0,
           tile_w: 100,
           tile_h: 100
       } 
    end

    def ui_button_skill
        {
            x: 100,
            y: 430,
            w: 100,
            h: 50,
            path: 'sprites/buttons.png',
            tile_x: 100,
            tile_y: 0,
            tile_w: 100,
            tile_h: 100
        }
    end

    def ui_button_spell
        {
            x: 100,
            y: 360,
            w: 100,
            h: 50,
            path: 'sprites/buttons.png',
            tile_x: 200,
            tile_y: 0,
            tile_w: 100,
            tile_h: 100
        }
    end

    def ui_back
        {
            x: 50,
            y: 100,
            w: 50,
            h: 50,
            path: 'sprites/back_button.png',
        }
    end
    
    def ui_button_int
        {
            x: 100,
            y: 500,
            w: 100,
            h: 50,
            path: 'sprites/buttons.png',
            tile_x: 500,
            tile_y: 0,
            tile_w: 100,
            tile_h: 100
        }
    end

    def ui_stats
        {
            x: 100,
            y: 290,
            w: 100,
            h: 50,
            path: 'sprites/buttons.png',
            tile_x: 300,
            tile_y: 0,
            tile_w: 100,
            tile_h: 100
        }
    end

    def ui_weapon_cards
        {
            x: 350,
            y: 575,
            w: 75,
            h: 125,
            path: 'sprites/weapon_deck.png',
            tile_x: @hero.default_weapon * 50,
            tile_y: 0,
            tile_w: 50,
            tile_h: 100
        }
    end

    def draw_loot k
        {
            x: @pos_room_x + (k.x * @tile_w),
            y: @pos_room_y - (k.y * @tile_h) - @tile_h,
            w: @tile_w,
            h: @tile_h,
            path: 'sprites/weapon_icons.png',
            tile_x: k.icon * (@tile_w / 2),#@tiles[@room[a][b]],#*@tile_w,
            tile_y: 0,
            tile_w: @tile_w / 2,
            tile_h: @tile_h / 2
        }
    end

    def draw_habitation index
        {
            x: (@habitations[index].x * 32) + @pos_room_x,
            y: (-1 * @habitations[index].y * 32) + @pos_room_y - @tile_h,
            w: 32,
            h: 64,
            path: 'sprites/habbitations.png',
            tile_x: @habitations[index].image * 16,
            tile_y: 0,
            tile_w: 16,
            tile_h: 32
        }
    end

    def clicks()
            if inputs.mouse.point.inside_rect?([350,605,75,50])
                @guide.text = "This is a " + get_name(@hero.default_weapon).to_s
            end
            if inputs.mouse.point.inside_rect?([350,575,30,20])
                @guide.text = "This " + get_name(@hero.default_weapon).to_s + " applies " + @hero.default_weapon_stats.to_s + " to your attack roll."
                @guide.text += " Weighs " + (@hero.default_weapon_stats / 2).to_s if @hero.default_weapon_stats > 1
            end
                if @object_count > 0 
                   if distance(@elf_statue.x,@elf_statue.y) && inputs.mouse.point.inside_rect?([(@pos_room_x + (@elf_statue.x *  @tile_w)),( @pos_room_y - (@elf_statue.y * @tile_h) - @tile_h), 32, 32])
                        @guide.text = "This statue is of the Dwarven ruins"
                    end
                    if distance(@dwarf_statue.x,@dwarf_statue.y) && inputs.mouse.point.inside_rect?([(@pos_room_x + (@dwarf_statue.x *  @tile_w)),( @pos_room_y - (@dwarf_statue.y * @tile_h) - @tile_h), 32, 32])
             
                        @guide.text = "This statue is of the Elven empire"
                    end 
                end

               if distance(@guide.x,@guide.y) && inputs.mouse.point.inside_rect?([(@pos_room_x + (@guide.x *  @tile_w)),( @pos_room_y - (@guide.y * @tile_h) - @tile_h), 32, 32]) && (@hero.conversion > 0 || @hero.kills > 0)
                    @guide.text = "The guide has more to say, return to it."
               end
        for a in (0..@npc_count)
           # puts @pos_room_x + (@npc_deck_drawn[a].x *  @tile_w), @pos_room_y - (@npc_deck_drawn[a].y * @tile_h) - @tile_h
                if @choice == "nothing" && inputs.mouse.point.inside_rect?([(@pos_room_x + (@npc_deck_drawn[a].x *  @tile_w)),( @pos_room_y - (@npc_deck_drawn[a].y * @tile_h) - @tile_h), 32, 32])
                   @guide.text = @hero.flair(@npc_deck_drawn[a]).to_s if @choice == "nothing"
                   @choice = "examine"
                elsif @choice == "examine" && !inputs.mouse.point.inside_rect?([(@pos_room_x + (@npc_deck_drawn[a].x *  @tile_w)),( @pos_room_y - (@npc_deck_drawn[a].y * @tile_h) - @tile_h), 32, 32])
                    @choice = "looked"
                end
            end

            for m in (0..@habit_count)
                if @habit_count > 0  && inputs.mouse.point.inside_rect?([@pos_room_x + (@habitations[m-1].x *  @tile_w), @pos_room_y - (@habitations[m-1].y * @tile_h) - @tile_h,32,32])
                    @guide.text = "A simple habitatation. Total population is " + @population.values.inject { |a, b| a + b }.to_s
                    @guide.text += " come here for healing" if @hero.health < @hero.max_health
                    puts "true"
                else 
                    #puts "false"
                end
            end

        for z in (0..@size_w-1)
            for n in (0..@size_h-1)
                if @habit_count > 0 && inputs.mouse.point.inside_rect?([@pos_room_x + (@size_w/2 *  @tile_w), @pos_room_y - (@size_h/2 * @tile_h) - @tile_h,32,32])
                    @guide.text = "Click on me" if @guide.text != "Feature coming soon..."
                    if inputs.mouse.click && @guide.text == "Click on me"
                        @guide.text = "Feature coming soon..."
                    end
                end
            end
        end
        if inputs.mouse.point.inside_rect?([100,290,100,50]) && $game.state_of_menu_left == [:default]
            @guide.text = "VIEW YOUR STATS?"
            if inputs.mouse.click
                #@hero.select_target = true
                @guide.text = "VIEW STATS"
                $game.state_of_menu_left = [:stats]
                #@choice = "intimidate"
                #puts @npc_deck_drawn[@npc_count].x * 32 + @pos_room_x1
            end
        end
        if inputs.mouse.point.inside_rect?([50,100,50,50]) && $game.state_of_menu_left == [:stats]
            @guide.text = "CANCLE STATS?"
            if inputs.mouse.click
                #@hero.select_target = true
                @guide.text = "STATS CANCELED"
                $game.state_of_menu_left = [:default]
                #@choice = "intimidate"
                #puts @npc_deck_drawn[@npc_count].x * 32 + @pos_room_x
            end
        end
        if inputs.mouse.point.inside_rect?([100,500,100,50]) && $game.state_of_menu_left == [:skills]
            @guide.text = "BEGIN INTIMIDATION?"
            if inputs.mouse.click
                @hero.select_target = true
                @guide.text = "SELECT TARGET"
                #$game.state_of_menu_left = [:default]
                @choice = "intimidate"
                #puts @npc_deck_drawn[@npc_count].x * 32 + @pos_room_x
            end
        end
        if inputs.mouse.point.inside_rect?([100,360,100,50]) && $game.state_of_menu_left == [:default]
            @guide.text = "ENTER SPELLS?"
            if inputs.mouse.click
                #@hero.select_target = true
                @guide.text = "SELECT SPELL"
                $game.state_of_menu_left = [:spells]
                #@choice = "intimidate"
                #puts @npc_deck_drawn[@npc_count].x * 32 + @pos_room_x
            end
        end
        if inputs.mouse.point.inside_rect?([50,100,50,50]) && $game.state_of_menu_left == [:spells]
            @guide.text = "CANCLE SPELLS?"
            if inputs.mouse.click
                #@hero.select_target = true
                @guide.text = "SPELLS CANCELED"
                $game.state_of_menu_left = [:default]
                #@choice = "intimidate"
                #puts @npc_deck_drawn[@npc_count].x * 32 + @pos_room_x
            end
        end
        if inputs.mouse.point.inside_rect?([100,430,100,50]) && $game.state_of_menu_left == [:default]
            @guide.text = "ENTER SKILLS?"
            if inputs.mouse.click
                #@hero.select_target = true
                @guide.text = "SELECT SKILL"
                $game.state_of_menu_left = [:skills]
                #@choice = "intimidate"
                #puts @npc_deck_drawn[@npc_count].x * 32 + @pos_room_x
            end
        end
        if inputs.mouse.point.inside_rect?([50,100,50,50]) && $game.state_of_menu_left == [:skills]
            @guide.text = "CANCLE SKILLS?"
            if inputs.mouse.click
                #@hero.select_target = true
                @guide.text = "SKILLS CANCELED"
                $game.state_of_menu_left = [:default]
                #@choice = "intimidate"
                #puts @npc_deck_drawn[@npc_count].x * 32 + @pos_room_x
            end
        end
        if inputs.mouse.point.inside_rect?([100,500,100,50])  && @hero.select_target == false && @npc_count > 0 && $game.state_of_menu_left == [:default]
            #puts @npc_deck_drawn[1].x, @npc_deck_drawn[1].y
            @guide.text = "ENTER COMBAT?"
            if inputs.mouse.click
                @hero.select_target = true
                @guide.text = "SELECT TARGET"
                @choice = "attack"
                #puts @npc_deck_drawn[@npc_count].x * 32 + @pos_room_x
            end
        end
        if inputs.mouse.point.inside_rect?([100,500,100,50]) && @npc_count < 0 && $game.state_of_menu_left == [:default]
            @guide.text = "NO COMBATANT AVAILABLE"
        end
       # puts inputs.mouse.point
       #     puts @hero.select_target
        #    puts ((32 * @npc_deck_drawn[1].x) + @pos_room_x).to_s + "xnpc", ((32 * @npc_deck_drawn[1].y) + @pos_room_y) .to_s + "ynpc" if @npc_count > 0
        if inputs.mouse.click
            puts inputs.mouse.point
            puts (@npc_deck_drawn[1].y * 32) + @pos_room_y if @npc_count > 0
            #puts inputs.mouse.x.to_s + "xmouse".Math.modulo(5)
            #puts ((32 * @npc_deck_drawn[1].x) + @pos_room_x).to_s + "xnpc", ((32 * @npc_deck_drawn[1].y) + @pos_room_y) .to_s + "ynpc" if @npc_count > 0
            
        end
        #puts inputs.mouse.point.inside_rect?([(@npc_deck_drawn[1].x) + @pos_room_x, (@npc_deck_drawn[1].y) + @pos_room_x, @tile_w, @tile_h]) if @npc_count > 0
        for a in (0..@npc_count)
           #puts @npc_deck_drawn[a]
            if @hero.select_target == true && inputs.mouse.point.inside_rect?([(@npc_deck_drawn[a].x * 32) + @pos_room_x, (-1 * @npc_deck_drawn[a].y * 32) + @pos_room_y -32, @tile_w, @tile_h]) && @npc_deck_drawn[a].names != "GUIDE" #&& characters[a][b] != @samples[:wall] #&& inputs.mouse.click
                @guide.text = "NPC SELECTED CLICK TO ENGAGE"
                if inputs.mouse.click && @choice == "attack"
                    @hero.target = @npc_deck_drawn[a]
                    if distance_melee(@npc_deck_drawn[a].x, @npc_deck_drawn[a].y)
                        attack(@hero,@hero.target) 
                    else
                        @guide.text = "TARGET TOO FAR"
                    end
                    @hero.select_target = false
                end
                if inputs.mouse.click && @choice == "intimidate"
                    @hero.target = @npc_deck_drawn[a]
                    intimidate(@hero.target)
                    @hero.select_target = false
                end
            end
        end
    end

    def intimidate target
        @base = roll_d6()
        @total = @base + @hero.skills[:intimidate]
        @dc = roll_d6() + target.stats[:melee]
        if @total >= @dc 
            convert(target)
        else
            @guide.text = "FAILED TO CONVERT " + target.names + " " + @hero.names + " ROLLED A " + @total.to_s + " DC WAS " + @dc.to_s
        end
        if @total == 1
            @guide.text = "CRITICAL FAIL!"
            target.initiate = true
            retaliation(target, @hero)
            target.initiate = false
        end
    end

    def convert target 
        @guide.text = "Thank you, " + @hero.names + ". I will do you no harm."
        #puts @population[target.race]
        if @population[target.race] % 5 == 0
            spawn_habitation(target)
            spawn_loot(target)
            @hero.conversion += 1
            if npc_count == 0
                light_token()
            end
        else
            @population[target.race] += 1
            @npc_deck_drawn.delete_at(target.id_t)
            @npc_count -= 1
            #puts @population
            @characters[target.x][target.y] = @samples[:floors]
        end
    end

    def spawn_habitation target
        puts @habitations.count.to_s + "Number of habitations"
        puts @samples
        if @population[target.race] % 5 == 0 
            @temp_count = @habit_count + 1
            puts "temp added"
        else
            @temp_count = @habit_count
            puts "temp voided"
        end
        puts "Begin search"
        for a in (0..@size_w-1)
            for b in (0..@size_h-1)
                # puts (@characters[a][b] == @samples[:floors]).to_s + "floor?" #&& b > 0 && @characters[a][b - 1 ] == @samples[:floors] 
                # puts @characters[a].to_s + " stuffs"
                # puts @temp_count.to_s + " > " + @habit_count.to_s
                if @characters[a][b] == 9 && b > 0 && a > 0 && b < @size_w-1 && a < @size_h - 1 && @temp_count > @habit_count && @characters[a][b-1] && @characters[a][b-1] == 9 && @characters[a+1][b] == 9 && @characters[a-1][b] == 9
                    @habitations << Habitation.new
                    puts "habitation added"
                    @habitations[@habit_count].x = a
                    @habitations[@habit_count].image = target.building
                    @habitations[@habit_count].y = b
                    @characters[a][b] = @samples[:wall]
                    puts @habitations[@habit_count].image.to_s + " image index"
                    @habit_count += 1
                else
                    # puts "space occupied: "  + @characters[a][b].to_s + " " + a.to_s + "|" + b.to_s
                    # puts "looking for:  " + @samples[:floors].to_s
                    # puts @temp_count.to_s + " > " + @habit_count.to_s
                end
            end
        end
        @population[target.race] += 1
        @npc_deck_drawn.delete_at(target.id_t)
        @npc_count -= 1
        @characters[target.x][target.y] = @samples[:floors]
        #puts @population
    end

    def timer t, atk
        if t.elapsed? && @choice == "attack"
            @guide.text = "RETALIATION!" unless @guide.text == "TARGET IS DEAD"
            puts "retaliation"
            ai()
            $trigger = false
        elsif t.elapsed? && @choice != "attack"
            @choice = "nothing"
            ai()
            $trigger = false
        end
    end

    def ai
                retaliation(@hero.target,@hero)
                @choice = "nothing"
    end

    def attack atk, defe
        @damage_base = roll_d6() 
        puts @damage_base 
        puts atk
        @damage_total = @damage_base + atk.default_weapon 
        @dc = defe.base_dc
        if @damage_total >= @dc && defe.red != 4
            defe.stats[apply_damage(defe)] -= 1 if defe.red < 3
            defe.health -= 1
            puts "hit" + "dc" + @dc.to_s + " atk " + @damage_total.to_s + " to " + defe.names
        else
            puts "dc" + @dc.to_s + " atk " + @damage_total.to_s + " to " + defe.names
            @guide.text = "MISS " + @dc.to_s  + " " + defe.names
        end
        check_defender_stats(defe)
        defe.initiate = true if defe != @hero
        puts defe.initiate.to_s + " retaliate?" unless defe.names == @hero.names
    end

    def retaliation defe, atk
        attack(defe,atk) unless @guide.text == "TARGET IS DEAD"
        @hero.target = nil
        defe.initiate = false
    end

    def roll_d6
        return rand(5) + 1
    end

    def spawn_loot target
        if @room_number == 0
            @loot << Weapon_Cards.new
            @loot[@loot_count].icon = 1
            @loot[@loot_count].x = target.x
            @loot[@loot_count].y = target.y
            @loot[@loot_count].names = "Dagger"
            @guide.text = "Walk on the loot to equip."
            @loot_count += 1
        end
    end

    def light_token
        @characters[@size_w/2][@size_h/2] = @samples[:token]
        @domain = true
    end

    def check_defender_stats(defe)
        @check = [ :melee, :ranged, :touch, :ranged_magic ]
        for a in (0..4)
            if defe.stats[@check[a]] < 0
                @red += 1
            end
            if @red == 4
                @guide.text = "TARGET IS DEAD" 
                $trigger = false
                if defe.names != @hero.names
                    spawn_loot(defe)
                    @hero.kills += 1
                    light_token() if @npc_count == 0
                end
            end
        end
        @red = 0
    end

    def apply_damage defe
        @check = [ :melee, :ranged, :touch, :ranged_magic ]
        for a in (0...3)
            if defe.stats[@check[a]] > 0 
                puts @guide.text = @check[a].to_s + " reduced for " + defe.names
                return @check[a]
            else
                defe.red += 1 
            end
        end
        apply_damage(defe) unless defe.red == 3
    end

    def distance a, b
        if (@hero.x - a).abs + (@hero.y - b).abs > @hero.line_of_sight
            #puts "far"
            return false 
        else
            return true
        end
    end

    def distance_melee a, b
        if (@hero.x - a).abs + (@hero.y - b).abs > 2
            #puts "far"
            return false 
        else
            return true
        end
    end

    def take_loot i 
        @hero.default_weapon = @loot[i-1].icon
        if @loot[i-1].icon == 1
            @hero.klass = :cleric
            @hero.klass_cleric()
        end
        @hero.encumbrance = @hero.default_weapon
        @hero.default_weapon_stats = @loot[i-1].stats[@loot[i-1].icon]
        @loot_count -= 1
        @loot.delete_at(i)
    end

    def input args
        if inputs.keyboard.key_down.e 
            $gtk.reset seed: rand(100000)
            $game = nil
            $time_now = 0
        end
        # if inputs.keyboard.key_down.q
        #     if @loot_count > 0
        #         for i in (0..@loot_count-1)
        #             @guide.text = "New Item Acquired! " + @loot[i].icon.keys.to_s if i > 0 && distance(@loot[i].x,@loot[i].y)
        #             take_loot(i)
        #         end
        #     end
        # end
        if inputs.keyboard.key_down.raw_key
            @guide.text = ""
            if @guide.chapter == 0 && @guide.page == 1
                spawn_objects()
            end
            @choice = "nothing" if @choice == "looked"
            puts @characters[@hero.x][@hero.y]
            #@trigger = true
        end
        if inputs.keyboard.key_down.one
            if @npc_count < 1 && @hero.race != :noone && @room_number == 0
                spawn_npcs()
            end
        end
        for a in (0..@loot_count-1)
            if [@hero.x,@hero.y,1,1].inside_rect?([@loot[a].x,@loot[a].y,1,1])
                @guide.text = "Press Q to take the loot " + @loot[a].names.to_s
                if inputs.keyboard.key_down.q
                    take_loot(a)
                end
            end
        end
        if inputs.keyboard.key_down.left
            if @characters[@hero.x - 1][@hero.y] == @samples[:floors]
                @characters[@hero.x][@hero.y] = @samples[:floors]
                @hero.x -= 1
                @trigger = true
                $game.play_foot_steps($game.args) if $game.args.audio[:footsteps] == nil
            end
            if @characters[@hero.x - 1][@hero.y] == @samples[:guide_p]
                @guide.text = @guide.book[@guide.chapter][@guide.page]
                @guide.turn_page
                @in_dialogue = true
            end
            if @characters[@hero.x - 1][@hero.y] == @samples[:elf_statue]
                erase_statues()
                @guide.chapter += 1
                @guide.page = 0
                @guide.text = @guide.book[@guide.chapter][@guide.page]
                @hero.race = :elf
                @hero.init_elf()
            end
            if @characters[@hero.x - 1][@hero.y] == @samples[:dwarf_statue]
                erase_statues()
                @guide.chapter = 2
                @guide.page = 0
                @guide.text = @guide.book[@guide.chapter][@guide.page]
                @hero.race = :dwarf
                @hero.init_dwarf()
            end
        end
        if inputs.keyboard.key_down.right
            if @characters[@hero.x + 1][@hero.y] == @samples[:floors]
                @characters[@hero.x][@hero.y] = @samples[:floors]
                @hero.x += 1
                @trigger = true
                $game.play_foot_steps(args) if $game.args.audio[:footsteps] == nil
            end
            if @characters[@hero.x + 1][@hero.y] == @samples[:guide_p]
                @guide.text = @guide.book[@guide.chapter][@guide.page]
                @guide.turn_page
                @in_dialogue = true
            end
            if @characters[@hero.x + 1][@hero.y] == @samples[:elf_statue]
                erase_statues()
                @guide.chapter += 1
                @guide.page = 0
                @guide.text = @guide.book[@guide.chapter][@guide.page]
                @hero.race = :elf
                @hero.init_elf()
            end
            if @characters[@hero.x + 1][@hero.y] == @samples[:dwarf_statue]
                erase_statues()
                @guide.chapter = 2
                @guide.page = 0
                @guide.text = @guide.book[@guide.chapter][@guide.page]
                @hero.race = :dwarf
                @hero.init_dwarf()
            end
        end
        if inputs.keyboard.key_down.down
            if @characters[@hero.x][@hero.y + 1] == @samples[:floors]
                @characters[@hero.x][@hero.y] = @samples[:floors]
                @hero.y += 1
                @trigger = true
                $game.play_foot_steps(args) if $game.args.audio[:footsteps] == nil
            end
            if @characters[@hero.x][@hero.y+1] == @samples[:guide_p]
                @guide.text = @guide.book[@guide.chapter][@guide.page]
                @guide.turn_page
                @in_dialogue = true
            end
            if @characters[@hero.x ][@hero.y + 1] == @samples[:elf_statue]
                erase_statues()
                @guide.chapter += 1
                @guide.page = 0
                @guide.text = @guide.book[@guide.chapter][@guide.page]
                @hero.race = :elf
                @hero.init_elf()
            end
            if @characters[@hero.x][@hero.y + 1] == @samples[:dwarf_statue]
                erase_statues()
                @guide.chapter = 2
                @guide.page = 0
                @guide.text = @guide.book[@guide.chapter][@guide.page]
                @hero.race = :dwarf
                @hero.init_dwarf()
            end
        end
        if inputs.keyboard.key_down.up
            if @characters[@hero.x][@hero.y - 1] == @samples[:floors]
                @characters[@hero.x][@hero.y] = @samples[:floors]
                @hero.y -= 1
                @trigger = true
                $game.play_foot_steps(args) if $game.args.audio[:footsteps] == nil
            end
            if @characters[@hero.x][@hero.y-1] == @samples[:guide_p]
                @guide.text = @guide.book[@guide.chapter][@guide.page]
                @guide.turn_page
                @in_dialogue = true
            end
            if @characters[@hero.x ][@hero.y - 1] == @samples[:elf_statue]
                erase_statues()
                @guide.chapter += 1
                @guide.page = 0
                @guide.text = @guide.book[@guide.chapter][@guide.page]
                @hero.race = :elf
            end
            if @characters[@hero.x][@hero.y - 1] == @samples[:dwarf_statue]
                erase_statues()
                @guide.chapter = 2
                @guide.page = 0
                @guide.text = @guide.book[@guide.chapter][@guide.page]
                @hero.race = :dwarf
            end
        end
    end

    def erase_statues
        @characters[@elf_statue.x][@elf_statue.y] = @samples[:floors]
        @characters[@dwarf_statue.x][@dwarf_statue.y] = @samples[:floors]
        @object_count = 0
        @elf_statue = nil
        @dwarf_statue = nil
    end

    def spawn_objects
        @elf_statue = Objects.new
        @dwarf_statue = Objects.new
        @elf_statue.x = (@guide.x - @hero.x).clamp(3,@size_w-1)
        @elf_statue.y = (@guide.y - @hero.y).clamp(2,@size_h-1)
        @dwarf_statue.x = (@guide.x - @hero.x - 1).clamp(3,@size_w-1)
        @dwarf_statue.y = (@guide.y - @hero.y - 1).clamp(3,@size_h-1)
        @characters[@elf_statue.x][@elf_statue.y] = @samples[:elf_statue]
        @characters[@dwarf_statue.x][@dwarf_statue.y] = @samples[:dwarf_statue]
        @object_count += 2
    end

    def gen_coords
        @x = rand @size_w - 1
        @y = rand @size_w - 1
        @x += 1 if @x == 0
        @y += 1 if @y == 0
        if @characters[@x][@y] != @samples[:floors]
            gen_coords()
        end
        return [@x, @y]
    end

    def spawn_npcs
                @npc_deck_drawn << Npc.new
                @npc_count += 1
                @npc_deck_drawn[@npc_count].id_t = @npc_count - 1
                @coords = gen_coords()
                puts @coords
                @npc_deck_drawn[@npc_count].x = @coords[0]
                @npc_deck_drawn[@npc_count].y = @coords[1]  
                @characters[@npc_deck_drawn[@npc_count].x][@npc_deck_drawn[@npc_count].y] = @npc_deck_drawn[@npc_count].races[@npc_deck_drawn[@npc_count].race]
                #puts (@npc_deck_drawn[@npc_count].y - @pos_room_y).to_s + "y"
                #puts @npc_deck_drawn[@npc_count].names
                @guide.text = "NPC has been detected!1.0"
    end

    def update
        @characters[@hero.x][@hero.y] = @hero.races[@hero.race]
    end
end


class DM
    attr_gtk
    attr :state_of_menu_left, :state_of_menu_top, :rooms, :world_size_w, :world_size_h, :current_room, :music_list, :music_current, :volume

    def initialize
        @state_of_menu_left = [:default]
        @state_of_menu_top = [:default]
        @rooms = []
        @rooms << Room.new
        @current_room = 0
        @rooms[@current_room].room_number = 0
        puts @rooms[@current_room].hero
        @music_list = ["knights_of_kalvgv_main_theme.ogg","knights_of_kalvgv_main_theme_variant_2.ogg","knights_of_kalvgv_main_theme_variant_3.ogg"]
        @music_current = @music_list.sample
        #puts audio[:my_audio]
    end

    def play_music args
        args.audio[:my_audio] = {
            input: "sounds/"+@music_current,  # Filename
            x: 0.0, y: 0.0, z: 0.0,   # Relative position to the listener, x, y, z from -1.0 to 1.0
            gain: 0.6,                # Volume (0.0 to 1.0)
            pitch: 1.0,               # Pitch of the sound (1.0 = original pitch)
            paused: false,            # Set to true to pause the sound at the current playback position
            looping: false,           # Set to true to loop the sound/music until you stop it
          }
    end

    def play_foot_steps args
        args.audio[:footsteps] = {
            input: "sounds/sfx_footsteps.ogg",  # Filename
            x: 0.0, y: 0.0, z: 0.0,   # Relative position to the listener, x, y, z from -1.0 to 1.0
            gain: 1.0,                # Volume (0.0 to 1.0)
            pitch: 1.0,               # Pitch of the sound (1.0 = original pitch)
            paused: false,            # Set to true to pause the sound at the current playback position
            looping: false,           # Set to true to loop the sound/music until you stop it
        }
    end

    def check_healing_near
        if @rooms[@current_room].habit_count > 0
            for a in (0..@rooms[@current_room].habit_count)
                if distance_habitat(@rooms[@current_room].habitations[a-1], @rooms[@current_room].hero)
                    heal_player(@rooms[@current_room].hero) if @rooms[@current_room].hero.max_health != @rooms[@current_room].hero.health
                end
            end
        end
    end

    def heal_player target
        if target.stats[:melee] < target.max_stats[:melee]
            target.stats[:melee] += 1
            target.health += 1
            return puts "healed melee"
        elsif target.stats[:ranged] < target.max_stats[:ranged]
            target.stats[:ranged] += 1
            target.health += 1
            return puts "healed ranged"
        return true
       else
        return false
       end
    end

    def tick args
        $time_now ||= 0
        $trigger ||= false
        if @rooms[@current_room].hero.line_of_sight == 3 && @rooms[@current_room].hero.race == :elf || @rooms[@current_room].hero.race == :dwarf
            @rooms[@current_room].hero.line_of_sight = 5
        end
        for i in (0..@rooms[@current_room].npc_count)
            #puts $time_now
            if @rooms[@current_room].hero.target != nil && @rooms[@current_room].hero.target.initiate == true && $time_now < state.tick_count && $trigger == false
                $time_now = state.tick_count + 45
                puts $time_now.to_s + " count to"
                $trigger = true
            end
            if @rooms[@current_room].npc_deck_drawn[i].initiate == true
                @rooms[@current_room].timer($time_now, @rooms[@current_room].npc_deck_drawn[i])
            end
        end

        for a in (0...@rooms[@current_room].size_w)
            for b in (0...@rooms[@current_room].size_h)
                outputs.sprites << @rooms[@current_room].world(a,b) if @rooms[@current_room].distance(a,b) #[@pos_room_x + (a * 16), @pos_room_y - (b* 16), @tile_w, @tile_h, 'sprites/world.png', @tiles[@room[a][b]]*16,0,@tile_w,@tile_h]
                outputs.sprites << @rooms[@current_room].character_render(a,b) if @rooms[@current_room].distance(a,b)#[@pos_room_x + (a * 16), @pos_room_y - (b* 16), @characters[a][b]]
            end
        end
        outputs.sprites << @rooms[@current_room].ui_left_bg()
        for j in (0...@rooms[@current_room].habit_count)
            outputs.sprites << @rooms[@current_room].draw_habitation(j) if @rooms[@current_room].habit_count > 0 && @rooms[@current_room].distance(@rooms[@current_room].habitations[j].x,@rooms[@current_room].habitations[j].y)
        end
        for k in (0...@rooms[@current_room].loot_count)
            outputs.sprites << @rooms[@current_room].draw_loot(@rooms[@current_room].loot[k - 1])
        end
            #puts j
            if @state_of_menu_left == [:default]
                outputs.sprites << @rooms[@current_room].ui_button_atk()
                outputs.sprites << @rooms[@current_room].ui_button_skill()
                outputs.sprites << @rooms[@current_room].ui_button_spell()
                outputs.sprites << @rooms[@current_room].ui_stats()
            elsif @state_of_menu_left == [:skills] || @state_of_menu_left == [:spells] || @state_of_menu_left == [:stats]
                outputs.sprites << @rooms[@current_room].ui_back()
            end
        if @state_of_menu_left == [:skills]
            outputs.sprites << @rooms[@current_room].ui_button_int()
        end
        if @state_of_menu_left == [:stats]
            outputs.labels << [80, 520, "STAT BLOCK"]
            outputs.labels << [80, 500, @rooms[@current_room].hero.stats[:melee].to_s + " M"]
            outputs.labels << [80, 480, @rooms[@current_room].hero.stats[:ranged].to_s + " R"]
            outputs.labels << [80, 460, @rooms[@current_room].hero.stats[:touch].to_s + " TM"]
            outputs.labels << [80, 440, @rooms[@current_room].hero.stats[:ranged_magic].to_s + " RM"]
            outputs.labels << [88,420, "SKILLS_____________"]
            outputs.labels << [88,400, @rooms[@current_room].hero.skills[:thievery].to_s + " THIEF"]
            outputs.labels << [88, 380, @rooms[@current_room].hero.skills[:stealth].to_s + " STEALTH"]
            outputs.labels << [88, 360, @rooms[@current_room].hero.skills[:healing].to_s + " HEALING"]
            outputs.labels << [88, 340, @rooms[@current_room].hero.skills[:mend].to_s + " MENDING"]
            outputs.labels << [88, 320, @rooms[@current_room].hero.skills[:lockpicking].to_s + " PICKLOCKS"]
            outputs.labels << [88, 300, @rooms[@current_room].hero.skills[:intimidate].to_s + " INTIMIDATE"]
            outputs.labels << [88, 280, @rooms[@current_room].hero.skills[:jump].to_s + " JUMP"]
            outputs.labels << [88, 260, @rooms[@current_room].hero.skills[:dash].to_s + " DASH"]
        end
        outputs.labels << [80,600, @rooms[@current_room].hero.health.to_s + " HP"]
        outputs.sprites << @rooms[@current_room].ui_top_bg()
        outputs.sprites << @rooms[@current_room].ui_weapon_cards()
        outputs.sprites << [10,10, 500, 70, "sprites/music_info.png"]
        outputs.labels << [20,70,@music_current.to_s]
        outputs.labels << [20,50,"by Shandor Jackson"]
        #outputs.labels << [100,200,@room]
        outputs.labels << [350, 555, @rooms[@current_room].guide.text]
        @rooms[@current_room].input(args)
        @rooms[@current_room].clicks()
        @rooms[@current_room].update() if inputs.keyboard.key_down.raw_key
        check_healing_near()
    end

end

def tick args
    $game ||= DM.new
    $game.args = args and $game.rooms[$game.current_room].args = args and $game.args.state = args.state and $game.tick(args)
    $game.music_current = $game.music_list.sample and $game.play_music(args) if $game.args.audio[:my_audio] == nil
    $game.args.audio = args.audio #and puts args.audio
end
