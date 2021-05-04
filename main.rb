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
    attr :red, :health, :id, :decision, :decision_timer, :path_to_locations, :destination, :agressor, :max_health, :learned_tiles_to_avoid, :dc_intelect
    attr :tile_learning_index, :memory_location, :memory_timer, :jump_to, :stealth_dc_against
    
    def initialize
        @races  = { elf: 1, dwarf: 3, goblin: 4, troll: 5}
        @b_races = { elf: 0, dwarf: 1, goblin: 2, troll: 3 }
        @building = 0
        puts @stats
        @x      = rand 1280
        @y      = rand 720
        @race   = @races.keys.sample
        @red = 0
        @klass  = [:wizard, :cleric, :rogue, :ranger].sample
        @skills = { thievery: 0, stealth: 0, healing: 0, mend: 0, lockpicking: 0, intimidate: 0, jump: 0, dash: 0 }
        @dc_intelect = 0
        @stealth_dc_against = 0
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
        @decision = "idle"
        @decision_timer = 0
        @path_to_locations = Array.new(4) { Array.new(2, 0) }
        @destination = []
        @names = "NPC"
        @health = 8
        @max_health = @health
        @agressor = nil
        @id = [:npc]
        @tile_learning_index = 0
        @jump_to = []
        @learned_tiles_to_avoid = Array.new(@dc_intelect) { Array.new(2, 0) } if @names != "guide"
        @book = [["Welcome","Tell me about yourself"],
        ["So you are an Elf","Magic folk are wonderful"],
        ["So you are a Dwarf","Must miss the old mines"],["Well this is the setting","Press 1 to draw a card from the NPC deck...","Now clear the room"],
        ["Well done. You can convert or kill an enemy to clear a room.", "Clearing a room makes it apart of your domain.", "After all, you are the sovereign temporarily.","Go to the light token in the center.","It will give you a tunnel card."],
        ["The tunnel cards can be used on walls.", "There must be 8 tiles between each tunnel"]
        ]
        @memory_location = []
        @memory_timer = 0
    end

    def set_locations loc
        @xx = rand($game.rooms[$game.current_room].size_w).clamp(1,$game.rooms[$game.current_room].size_w - 1)
        @yy = rand($game.rooms[$game.current_room].size_h).clamp(1,$game.rooms[$game.current_room].size_h - 1)
        if $game.rooms[$game.current_room].characters[@xx][@yy] != $game.rooms[$game.current_room].samples[:floors]
            set_locations(loc)
        end
        @path_to_locations[loc] = [@xx,@yy] if @path_to_locations[loc] == nil || @path_to_locations[loc][0] == 0
        if loc < 4
            loc += 1
            set_locations(loc)
        end
        puts @path_to_locations
    end

    def set_jump
        @jump = (rand(5)+1 + @skills[:jump])/2
        @difx = [-1,1].sample * @jump
        @dify = [-1,1].sample * @jump
        for a in (0..@tile_learning_index-1)
            if @x + @difx == @learned_tiles_to_avoid[a][0] &&  @y + @dify == @learned_tiles_to_avoid[a][1]
                @difx *= -1
                @dify *= -1
            end
        end
        if $game.rooms[$game.current_room].characters[@x + @difx][@y +  @dify] == $game.rooms[$game.current_room].samples[:floors]
            walk(@difx+@x,@dify+@y)
        else
            set_jump()
        end
    end

    def init_elf
        @stats = { melee: 1, ranged: 3, touch: -1, ranged_magic: 5 }
        @skills = { thievery: -1, stealth: 5, healing: -1, mend: 5, lockpicking: 1, intimidate: 1, jump: 3, dash: 3 }
        @building = @b_races[:elf]
        @base_dc = 3
        @dc_intelect += 4
        @health = 8
    end

    def init_dwarf
        @stats = { melee: 3, ranged: 1, touch: 5, ranged_magic: -1 }
        @skills = { thievery: 5, stealth: -1, healing: 5, mend: -1, lockpicking: 3, intimidate: 3, jump: 1, dash: 1 }
        @building = @b_races[:dwarf]
        @base_dc = 4
        @dc_intelect += 4
        @health = 8
    end

    def init_goblin
        @stats = { melee: 4, ranged: 2, touch: -1, ranged_magic: 3 }
        @skills = { thievery: -1, stealth: 3, healing: -1, mend: 3, lockpicking: 4, intimidate: 4, jump: 2, dash: 2 }
        @building = @b_races[:goblin]
        @base_dc = 2
        @dc_intelect += 2
        @health = 8
    end

    def init_troll
        @stats = { melee: 5, ranged: -1, touch: 3, ranged_magic: -1 }
        @skills = { thievery: 3, stealth: -1, healing: 3, mend: -1, lockpicking: 5, intimidate: 5, jump: -1, dash: -1 }
        @building = @b_races[:troll]
        @base_dc = 5
        @dc_intelect += 2
        @health = 8
    end

    def walk (target_x, target_y)
        @set = 0
        @memory_location = [@x,@y] if @memory_timer == 0
        @difx = (target_x - @x).clamp(-1,1)
        @dify = (target_y - @y).clamp(-1,1)
        for a in (0..@tile_learning_index-1)
            if @x + @difx == @learned_tiles_to_avoid[a][0] &&  @y + @dify == @learned_tiles_to_avoid[a][1]
                @difx *= -1
                @dify *= -1
            end
        end
            if $game.rooms[$game.current_room].characters[@x + @difx][@y] == $game.rooms[$game.current_room].samples[:floors] 
            @x += @difx
            #puts "walked x"
            else
                @set += 1
               # puts "blocked x"
            end
            if $game.rooms[$game.current_room].characters[@x ][@y + @dify] == $game.rooms[$game.current_room].samples[:floors] 
                @y += @dify
                #puts "walked y"
            else
                @set += 1
                #puts "blocked y"
            end
        if @set > 1
            set_destination()
            @memory_timer += 1
            #puts "rerouting"
        end
        if @memory_timer == 1 && @memory_location[0] == @x && @memory_location[1] == @y
            @decision = "jump"
        end
    end

    def set_destination
        @select = rand(3)
        if @destination[0] == 0
            
            @destination[0] = @path_to_locations[@select][0]
            @destination[1] = @path_to_locations[@select][1]
            return
        elsif @destination[0] == @x && @destination[1] == @y
            @destination[0] = @path_to_locations[@select][0]
            @destination[1] = @path_to_locations[@select][1]
            return
        else
            @destination[0] = @path_to_locations[@select][0]
            @destination[1] = @path_to_locations[@select][1]
        end
    end

    def idle
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
    attr :encumbrance, :carry_max, :health, :kills, :conversion, :default_weapon_stats, :max_stats, :max_health, :jump_distance
    attr :jump_to, :dash_distance, :dash_used, :dash_dir_x, :dash_dir_y, :skill_use, :skill_use_max, :stealth_roll, :stealth_actions
    def initialize
        @text = ""
        @races = { elf: 0, dwarf: 2, noone: 8}
        @race = :noone
        @skill_use = { thievery: 0, stealth: 0, healing: 0, mend: 0, lockpicking: 0, intimidate: 0, jump: 0, dash: 0 }
        @skill_use_max = { thievery: 1, stealth: 1, healing: 1, mend: 1, lockpicking: 1, intimidate: 1, jump: 1, dash: 1 }
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
        @jump_distance = 0
        @jump_to = []
        @dash_distance = 0
        @dash_dir_x = 0
        @dash_dir_y = 0
        @dash_used = 0
        @stealth_roll = -1
        @stealth_actions = 0
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
            @stats = { melee: 3, ranged: 1, touch: 6, ranged_magic: -1 }
            @max_stats = { melee: 3, ranged: 1, touch: 6, ranged_magic: -1 }
            @skills = { thievery: 6, stealth: -1, healing: 6, mend: -1, lockpicking: 3, intimidate: 3, jump: 1, dash: 1 }
            @health_ex = 1
        end
        if @race == :elf
            @stats = { melee: 1, ranged: 3, touch: 1, ranged_magic: 5 }
            @max_stats = { melee: 1, ranged: 3, touch: 1, ranged_magic: 5 }
            @skills = { thievery: 1, stealth: 5, healing: 1, mend: 5, lockpicking: 1, intimidate: 1, jump: 3, dash: 3 }
            @health_ex = 2
        end
        @max_health += @health_ex
        @health += @health_ex
        @health.clamp(0,@max_health)
    end

    def klass_wizard
        if @race == :dwarf
            @stats = { melee: 3, ranged: 1, touch: 5, ranged_magic: 1 }
            @max_stats = { melee: 3, ranged: 1, touch: 5, ranged_magic: 1 }
            @skills = { thievery: 5, stealth: 1, healing: 5, mend: 1, lockpicking: 3, intimidate: 3, jump: 1, dash: 1 }
        end
        if @race == :elf
            @stats = { melee: 1, ranged: 5, touch: -1, ranged_magic: 5 }
            @max_stats = { melee: 1, ranged: 5, touch: -1, ranged_magic: 5 }
            @skills = { thievery: -1, stealth: 5, healing: -1, mend: 5, lockpicking: 1, intimidate: 1, jump: 5, dash: 5 }
        end
        @health_ex  = 2
        @max_health += @health_ex
        @health += @health_ex
        @health.clamp(0,@max_health)
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
    attr :deck, :icon, :x, :y, :encumbrance_chart, :names, :stats, :name_list

    def initialize
        @deck = { unarmed: 0, dagger: 1, bow: 2 }
        @icon = { nothing: 0, dagger: 1, bow: 2 }
        @encumbrance_chart = { unarmed: 0, dagger: 1, bow: 1 }
        @x = 0
        @y = 0
        @stats = [1,2,2]
        @name_list = [ "Fist", "Dagger", "Bow"]
    end
end

class Tunnel_Cards
    attr :deck, :length, :width, :turn, :image

    def initialize
        @deck = { shoot: 0, turn_right: 1, turn_left: 2 }
        @length = { shoot: 4, turn_right: 2, turn_left: 2 }
        @width = { shoot: 1, turn_right: 2, turn_left: 2 }
        @turn = { shoot: 0, turn_right: 1, turn_left: -1 }
        @image = 0
    end
end

class Objects
    attr :text, :x, :y, :dc, :loot, :id

    def initialize
        @text = ""
        @x = 1
        @y = 1
        @loot = ""
        @dc = 0
        @id = [:object]
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
    attr :size_w, :size_h, :trigger, :room_number, :object_count, :npc_deck_drawn, :npc_count, :tile_w, :tile_h, :tiles, :in_dialogue, :characters, :habitations, :choice
    attr :damage_base, :damage_total, :dc, :reduction, :habitations, :habit_count, :population, :loot, :loot_count, :hero, :guide, :domain, :chests, :samples, :hazards
    attr :tunnel_cards, :tunnel_count, :tunnel_points

    def initialize
        #@npcs = (50 + rand(50)).map { Npc.new }
        @size_w = [8,10,12,14,16].sample
        @size_h = [8,10,12,14,16].sample
        @samples = { wall: 6, floors: 9, hero_place: 0, guide_p: 7, elf_statue: 10, dwarf_statue: 11, token: 12, chest: 13, selection: 14 }
        @tiles = { wall: 0, floors: 1, water: 2, lava: 3 }
        @room_size = @size_w + @size_h
        @pos_room_x = 1280/2
        @pos_room_y = (700/2) + 200
        @room_number = 0
        @npc_count = 0
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
        @chests = []
        @hazards = 0
        @tunnel_cards = []
        @tunnel_count = 0
        @tunnel_points = Array.new(@size_w) { Array.new(@size_h, 0) }
        for i in (0...@size_w) 
            for j in (0...@size_h)
                if (i == 0 || i == @size_w - 1 ) || (j == 0 || j == @size_h - 1 )
                    @room[i][j] = @tiles[:wall]
                    @characters[i][j] = @samples[:wall]
                else
                    @room[i][j] = @tiles[:floors]
                    if @room_number == 0 && @npc_count == 0 && rand(10) < 4
                        @guide = Npc.new
                        @guide.x = i
                        @guide.y = j
                        @guide.names = "GUIDE"
                        @characters[i][j] = @samples[:guide_p]
                        @npc_count += 1
                    else
                        @characters[i][j] = @samples[:floors]
                        @room[i][j] = @tiles[:lava] and @hazards += 1 and puts "hazard" if rand(30) < 2 && hazards < 3
                    end
                    if @object_count < 1 && rand(50) < 20 && @guide != nil && i != @guide.x && j != @guide.y
                        @chests << Objects.new
                        @chests[@object_count].x = i
                        @chests[@object_count].y = j
                        @chests[@object_count].dc = rand(6) + 1
                        @chests[@object_count].loot = 2
                        @characters[i][j] = @samples[:chest]
                        @object_count += 1
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
        @names = ["Fist","Dagger","Bow"]
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
            y: 430 - 70,
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

    def ui_button_stealth
        {
            x: 100,
            y: 500,
            w: 100,
            h: 50,
            path: 'sprites/buttons.png',
            tile_x: 1000,
            tile_y: 0,
            tile_w: 100,
            tile_h: 100
        }
    end

    def ui_button_heal
        {
            x: 100,
            y: 430,
            w: 100,
            h: 50,
            path: 'sprites/buttons.png',
            tile_x: 1100,
            tile_y: 0,
            tile_w: 100,
            tile_h: 100
        }
    end

    def ui_button_lock
        {
            x: 100,
            y: 430,
            w: 100,
            h: 50,
            path: 'sprites/buttons.png',
            tile_x: 600,
            tile_y: 0,
            tile_w: 100,
            tile_h: 100
        }
    end

    def ui_button_jump
        {
            x: 100,
            y: 430-70,
            w: 100,
            h: 50,
            path: 'sprites/buttons.png',
            tile_x: 700,
            tile_y: 0,
            tile_w: 100,
            tile_h: 100
        }
    end

    def ui_button_dash
        {
            x: 100,
            y: 430-140,
            w: 100,
            h: 50,
            path: 'sprites/buttons.png',
            tile_x: 800,
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

    def ui_button_magic
        {
            x: 100,
            y: 430-210,
            w: 100,
            h: 50,
            path: 'sprites/buttons.png',
            tile_x: 900,
            tile_y: 0,
            tile_w: 100,
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
    
    def roll_for_dash
        @base = roll_d6()
        @total = @base + @hero.skills[:dash]
        if @total > @hero.default_weapon_stats / 2
            return 4
        else
            return 2
        end
    end

    def check_remaining_stealth
        if @hero.stealth_actions < 5
        else
            @choice = "nothing"
            @hero.stealth_roll = -1
        end
    end

    def stealth_check_dc npc
        return puts "GUIDE IS EXCLUDED FROM STEALTH DC" if npc.names == "guide"
        npc.stealth_dc_against = roll_d6() + npc.stats[:ranged_magic]
        puts npc.names + " ROLLED AGAINST STEALTH WITH " + npc.stealth_dc_against.to_s
    end

    def clicks()
        check_remaining_stealth() if @hero.stealth_roll != -1
        if inputs.mouse.point.inside_rect?([100,430-210,100,50]) && $game.state_of_menu_left == [:skills] && @choice == "nothing"
            @guide.text = "MOVE TO MAGIC SKILLS?"
            if inputs.mouse.click
                $game.state_of_menu_left = [:magic_skills]
            end
        end
        if inputs.mouse.point.inside_rect?([50,100,50,50]) && $game.state_of_menu_left == [:magic_skills]
            @guide.text = "CANCLE MAGIC SKILLS?"
            if inputs.mouse.click
                #@hero.select_target = true
                @guide.text = "STATS CANCELED"
                $game.state_of_menu_left = [:skills]
                @choice = "nothing"
                #@choice = "intimidate"
                #puts @npc_deck_drawn[@npc_count].x * 32 + @pos_room_x
            end
        end

        if inputs.mouse.point.inside_rect?([100,500,100,50]) && $game.state_of_menu_left == [:magic_skills] && @choice == "nothing"
            @guide.text = "INITIATE STEALTH?" if @hero.skill_use[:stealth] < @hero.skill_use_max[:stealth]
            if inputs.mouse.click && @hero.skill_use[:stealth] < @hero.skill_use_max[:stealth]
                @choice = "stealth init"
                @hero.stealth_roll = roll_d6() + @hero.skills[:stealth]
                @guide.text = "ROLLED A " + @hero.stealth_roll.to_s + " TO BE UNSEEN."
                @npc_deck_drawn.each { |npc| stealth_check_dc(npc) }
            elsif inputs.mouse.click && @hero.skill_use[:stealth] < @hero.skill_use_max[:stealth]
                @guide.text = "YOU'VE USED THE MAXMIMUM NUMBER OF STEALTH"
            end
        end
        if inputs.mouse.point.inside_rect?([100,430,100,50]) && $game.state_of_menu_left == [:magic_skills] && @choice == "nothing"
            @to_heal = -1
            @guide.text = "INITIATE HEALING?" if @hero.skill_use[:healing] < @hero.skill_use_max[:healing] && @to_heal == -1
            if inputs.mouse.click && @hero.skill_use[:healing] < @hero.skill_use_max[:healing]
                @choice = "heal"
                @to_heal = check_defender_stats(@hero)
                @dc = roll_d6() + @hero.skills[:healing]
                if @to_heal != false && @dc > @hero.stats[@to_heal]  
                    @guide.text = "ROLLED A " + @dc.to_s + " TO HEAL " + @to_heal.to_s
                    @hero.stats[@to_heal] += 1
                    @hero.health += 1
                else
                    @guide.text = @dc.to_s + " IS NOT HIGH ENOUGH TO HEAL " + @to_heal.to_s
                end
                if @to_heal == false 
                    @guide.text = "YOU ARE ALREADY MAX HEALTH; HEALING ACTION NOT USED"
                else
                    @hero.skill_use[:healing] += 1
                end
            elsif inputs.mouse.click && @hero.skill_use[:stealth] < @hero.skill_use_max[:stealth]
                @guide.text = "YOU'VE USED THE MAXMIMUM NUMBER OF STEALTH"
            end
        end

        if inputs.mouse.point.inside_rect?([100,430-140,100,50]) && $game.state_of_menu_left == [:skills] && @choice == "nothing"
            @guide.text = "INITIATE DASH?" if @hero.skill_use[:dash] < @hero.skill_use_max[:dash]
            if inputs.mouse.click && @hero.skill_use[:dash] < @hero.skill_use_max[:dash]
                @hero.dash_distance = roll_for_dash()
                @guide.text = "PRESS A DIRECTION TO DASH " + @hero.dash_distance.to_s
                @choice = "dash"
            elsif inputs.mouse.click && @hero.skill_use[:dash] == @hero.skill_use_max[:dash]
                @guide.text = "YOU'VE USED THE MAXIMUM NUMBER OF DASH: " + @hero.skill_use_max[:dash].to_s
            end
        end
        if inputs.mouse.point.inside_rect?([100,430-70,100,50]) && $game.state_of_menu_left == [:skills]
            @guide.text = "INITIATE JUMP?" if @hero.skill_use[:jump] < @hero.skill_use_max[:jump]
            if inputs.mouse.click && @hero.skill_use[:jump] < @hero.skill_use_max[:jump]
                #@hero.select_target = true
                @guide.text = "SELECT A TILE TO JUMP TO"
                @hero.jump_distance = roll_d6 + @hero.skills[:jump]
                @choice = "jump"
                #puts @npc_deck_drawn[@npc_count].x * 32 + @pos_room_x
            elsif inputs.mouse.click && @hero.skill_use[:jump] == @hero.skill_use_max[:jump]
                @guide.text = "YOU'VE USED THE MAXIMUM NUMBER OF JUMPS: " + @hero.skill_use_max[:jump].to_s
            end
        end
        if @choice == "jump"
            @coord_x = (inputs.mouse.x - @pos_room_x )/ @tile_w
            @coord_y = (inputs.mouse.y - @pos_room_y) / -@tile_h
            if (@coord_x - @hero.x).abs < @hero.jump_distance && (@coord_y - @hero.y).abs < @hero.jump_distance 
                @guide.text = "In range " + @hero.jump_distance.to_s
                if @characters[@coord_x][@coord_y] == @samples[:floors]
                    @guide.text += " clear"
                    if inputs.mouse.click 
                        @choice = "execute jump"
                        @hero.jump_to = [@coord_x,@coord_y]
                        @hero.stealth_actions += 1 if @hero.stealth_roll != -1
                    end
                else
                    @guide.text += " not clear"
                end
            else
                @guide.text = @coord_x.to_s + " " + @coord_y.to_s
            end
        end
        if @choice == "execute jump"
            $game.time_redux = 4
        end
            if inputs.mouse.point.inside_rect?([350,605,75,50])
                @guide.text = "This is a " + get_name(@hero.default_weapon).to_s
            end
            if inputs.mouse.point.inside_rect?([350,575,30,20])
                @guide.text = "This " + get_name(@hero.default_weapon).to_s + " applies " + @hero.default_weapon_stats.to_s + " to your attack roll."
                @guide.text += " Weighs " + (@hero.default_weapon_stats / 2).to_s if @hero.default_weapon_stats > 1
            end
                if @object_count > 0
                   if @elf_statue != nil && distance(@elf_statue.x,@elf_statue.y) && inputs.mouse.point.inside_rect?([(@pos_room_x + (@elf_statue.x *  @tile_w)),( @pos_room_y - (@elf_statue.y * @tile_h) - @tile_h), 32, 32])
                        @guide.text = "This statue is of the Dwarven ruins"
                    end
                    if @dwarf_statute != nil && distance(@dwarf_statue.x,@dwarf_statue.y) && inputs.mouse.point.inside_rect?([(@pos_room_x + (@dwarf_statue.x *  @tile_w)),( @pos_room_y - (@dwarf_statue.y * @tile_h) - @tile_h), 32, 32])
             
                        @guide.text = "This statue is of the Elven empire"
                    end 
                    if @chests != nil && distance(@chests[0].x,@chests[0].y) && inputs.mouse.point.inside_rect?([(@pos_room_x + (@chests[0].x *  @tile_w)),( @pos_room_y - (@chests[0].y * @tile_h) - @tile_h), 32, 32])
                        @guide.text = "This contains something mysterious for wizards"
                    end
                end
               if distance(@guide.x,@guide.y) && inputs.mouse.point.inside_rect?([(@pos_room_x + (@guide.x *  @tile_w)),( @pos_room_y - (@guide.y * @tile_h) - @tile_h), 32, 32]) && (@hero.conversion > 0 || @hero.kills > 0)
                    @guide.text = "The guide has more to say, return to it."
               end
        for a in (0...@npc_count)
           # puts @pos_room_x + (@npc_deck_drawn[a].x *  @tile_w), @pos_room_y - (@npc_deck_drawn[a].y * @tile_h) - @tile_h
                if @choice == "nothing" && @hero.target == :noone && inputs.mouse.point.inside_rect?([(@pos_room_x + (@npc_deck_drawn[a].x *  @tile_w)),( @pos_room_y - (@npc_deck_drawn[a].y * @tile_h) - @tile_h), 32, 32])
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
                    @guide.text = "Click on me" if @guide.text != "You've got a card!"
                    if inputs.mouse.click && @guide.text == "Click on me"
                        @guide.text = "You've got a card!"
                        draw_tunnel_card()
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
                @choice = "nothing"
                #@choice = "intimidate"
                #puts @npc_deck_drawn[@npc_count].x * 32 + @pos_room_x
            end
        end
        if inputs.mouse.point.inside_rect?([100,430,100,50]) && $game.state_of_menu_left == [:skills]
            @guide.text = "BEGIN LOCKPICKING?" if @choice != "lockpick" && @hero.skill_use[:lockpicking] < @hero.skill_use_max[:lockpicking]
            if inputs.mouse.click && @hero.skill_use[:lockpicking] < @hero.skill_use_max[:lockpicking]
                @hero.select_target = true
                @guide.text = "SELECT TARGET"
                #$game.state_of_menu_left = [:default]
                @choice = "lockpick"
                #puts @npc_deck_drawn[@npc_count].x * 32 + @pos_room_x
            elsif inputs.mouse.click && @hero.skill_use[:lockpicking] == @hero.skill_use_max[:lockpicking]
                @guide.text = "YOU'VE USED THE MAXIMUM NUMBER OF LOCKPICKING: " + @hero.skill_use_max[:lockpicking].to_s
            end
            #puts @choice
        end
        if inputs.mouse.point.inside_rect?([100,500,100,50]) && $game.state_of_menu_left == [:skills]
            @guide.text = "BEGIN INTIMIDATION?" if @hero.skill_use[:intimidate] < @hero.skill_use_max[:intimidate]
            if inputs.mouse.click && @hero.skill_use[:intimidate] < @hero.skill_use_max[:intimidate]
                @hero.select_target = true
                @guide.text = "SELECT TARGET"
                #$game.state_of_menu_left = [:default]
                @choice = "intimidate"
                #puts @npc_deck_drawn[@npc_count].x * 32 + @pos_room_x
            elsif inputs.mouse.click && @hero.skill_use[:intimidate] == @hero.skill_use_max[:intimidate]
                @guide.text = "YOU'VE USED THE MAXIMUM NUMBER OF INTIMIDATION: " + @hero.skill_use_max[:intimidate].to_s
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
                @choice = "nothing"
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
                @choice = "nothing"
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
            #puts inputs.mouse.point
            #puts (@npc_deck_drawn[1].y * 32) + @pos_room_y if @npc_count > 0
            #puts inputs.mouse.x.to_s + "xmouse".Math.modulo(5)
            #puts ((32 * @npc_deck_drawn[1].x) + @pos_room_x).to_s + "xnpc", ((32 * @npc_deck_drawn[1].y) + @pos_room_y) .to_s + "ynpc" if @npc_count > 0
            
        end
        #puts inputs.mouse.point.inside_rect?([(@npc_deck_drawn[1].x) + @pos_room_x, (@npc_deck_drawn[1].y) + @pos_room_x, @tile_w, @tile_h]) if @npc_count > 0
        for a in (0..@npc_count-1)
           #puts @npc_deck_drawn[a]
            if @choice != "lockpick" && @hero.select_target == true && inputs.mouse.point.inside_rect?([(@npc_deck_drawn[a].x * 32) + @pos_room_x, (-1 * @npc_deck_drawn[a].y * 32) + @pos_room_y -32, @tile_w, @tile_h]) && @npc_deck_drawn[a].names != "GUIDE" #&& characters[a][b] != @samples[:wall] #&& inputs.mouse.click
                @guide.text = "NPC SELECTED CLICK TO ENGAGE"
                if inputs.mouse.click && @choice == "attack"
                    @hero.target = @npc_deck_drawn[a]
                    if distance_melee(@npc_deck_drawn[a].x, @npc_deck_drawn[a].y)
                        attack(@hero,@hero.target)
                        @choice = "attacked"
                    else
                        @guide.text = "TARGET TOO FAR"
                    end
                    @hero.select_target = false
                end
                if inputs.mouse.click && @choice == "intimidate"
                    @hero.target = @npc_deck_drawn[a]
                    intimidate(@hero.target)
                    @hero.select_target = false
                    @hero.skill_use[:intimidate] += 1
                end
            end
        end

        for n in (0..@object_count)
            if @choice == "lockpick" && @hero.select_target == true && @chests[n] != nil && inputs.mouse.point.inside_rect?([(@chests[n].x * 32) + @pos_room_x ,(-1 * @chests[n].y * 32) + @pos_room_y - 32,32,32])
                @guide.text = "CHEST SELECTED CLICK TO ENGAGE"
                if inputs.mouse.click && @hero.race != :noone
                    @hero.target = @chests[n]

                        puts "pick"
                       if picklock(@hero.target)
                        spawn_loot(@hero.target)
                        @hero.target = nil
                        @chests.delete_at(n)
                        @object_count -= 1
                        @choice = "nothing"
                        @hero.select_target = false
                        @hero.skill_use[:lockpicking] += 1
                       end
                end
                @guide.text = "SELECT A RACE FIRST" if @hero.race == :noone
            end
        end
    end

    def draw_tunnel_card
        @tunnel_cards << Tunnel_Cards.new 
        @tunnel_cards[@tunnel_count].image = @tunnel_cards[@tunnel_count].deck.keys.sample
        puts @tunnel_cards[@tunnel_count].deck[@tunnel_cards[@tunnel_count].image]
        @tunnel_count += 1
    end

    def picklock(target)
        @base = roll_d6() + @hero.skills[:lockpicking]
        if @base >= target.dc
            @guide.text = "Picked"
            @characters[target.x][target.y] = @samples[:floors]
            puts "success"
            return true
            $game.picked_s = true
        else
            @guide.text = "Failure DC: " + target.dc.to_s + " you rolled a " + @base.to_s
            puts "failure" + target.dc.to_s
            @choice = "nothing"
            return false
        end
        @hero.stealth_actions += 1 if @hero.stealth_roll != -1
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
        @hero.stealth_actions += 1 if @hero.stealth_roll != -1
    end

    def convert target 
        @guide.text = "Thank you, " + @hero.names + ". I will do you no harm."
        #puts @population[target.race]
        if @population[target.race] % 5 == 0
            spawn_habitation(target)
            spawn_loot(target)
            @hero.conversion += 1
            light_token() if @npc_count == 0 || (@npc_count == 1 && @room_number == 0)

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
        if t.elapsed? && @choice == "attack" && atk.names != "guide" && target.initiate == true
            @guide.text = "RETALIATION!" unless @guide.text == "TARGET IS DEAD"
            puts "retaliation"
            ai(atk)
            $trigger = false
        elsif t.elapsed? && @choice != "attack" && atk.names != "guide"
            @choice = "nothing"
            ai(atk)
        end
    end

    def ai target
        # puts @npc_count
        # puts @npc_deck_drawn[target.id_t].names
        if (target.initiate == true || target.agressor != nil) && distance_melee(target.x,target.y) && target.stealth_dc_against > @hero.stealth_roll
            retaliation(target,@hero) if @choice != "attacked"
            target.decision = "attack"
        end
        if target.decision == "idle" && target.names != "GUIDE"
            target.decision = "walk" if rand(6) > 4
        end
        if target.decision == "attack" && !distance_melee(target.x,target.y)
            if rand(6) > 3
                target.decision = "idle"
                target.initiate = false
            else
                target.decision = "walk"
                target.initiate = false
            end
        end
        if target.health < target.max_health / 2 && distance_melee(target.x,target.y)
            target.decision == "walk"
        end
        if target.decision == "walk"
            target.set_destination()
            @characters[target.x][target.y] = @samples[:floors]
            target.walk(target.destination[0],target.destination[1]) if target.names != "GUIDE"
            update_npc(target) if target.names != "GUIDE"
        end
        if target.decision == "jump"
            target.set_jump()
                    @characters[target.x][target.y] = @samples[:floors]
                    target.x += (target.jump_to[0] - target.x).clamp(-1,1)
                    target.y += (target.jump_to[1] - target.y).clamp(-1,1)
                    update_npc()
                if target.x == target.jump_to[0] && target.y == target.jump_to[1]
                    target.decision = "idle"
                end
        end
        if @room[target.x][target.y] == @tiles[:lava] && target.decision != "jump"
            target.stats[apply_damage(target)] -= 1
            target.health -= 1
            @dc_check_intelect = roll_d6()
            if target.tile_learning_index < 9 && @dc_check_intelect <= target.dc_intelect / 2 && target.learned_tiles_to_avoid[target.tile_learning_index][0] == 0
                target.learned_tiles_to_avoid[target.tile_learning_index][0] = target.x
                target.learned_tiles_to_avoid[target.tile_learning_index][1] = target.y
                target.tile_learning_index += 1
                puts "learned location"
                puts target.learned_tiles_to_avoid
            elsif @dc_check_intelect > target.dc_intelect / 2 && target.learned_tiles_to_avoid[target.tile_learning_index][0] == 0
                puts "unable to learn location"
            elsif target.learned_tiles_to_avoid[target.tile_learning_index][0] != 0
                puts "location already known"
            end
        end
        if target.health < 0
            @characters[target.x][target.y] = @samples[:floor]
            spawn_loot(target)
            @npc_deck_drawn.delete_at(target.id_t)
            @npc_count -= 1
        end
        #puts target.decision
    end

    def attack atk, defe
        @hero.stealth_actions += 1 if @hero.stealth_roll != -1 && atk.names == @hero.names
        @damage_base = roll_d6() 
        #puts @damage_base 
        #puts atk
        if defe.id == [:npc]
            defe.agressor = atk
        end
        @damage_total = @damage_base + atk.default_weapon 
        @dc = defe.base_dc
        if @damage_total >= @dc && apply_damage(defe != false
            @which = apply_damage(defe)
            defe.stats[@which] -= 1 if @which != false
            defe.health -= 1
            @guide.text = "hit " + "dc " + @dc.to_s + " atk " + @damage_total.to_s + " to " + defe.names + " on " + @which.to_s
            puts "hit " + "dc" + @dc.to_s + " atk " + @damage_total.to_s + " to " + defe.names + " on " + @which.to_s
        else
            puts "dc" + @dc.to_s + " atk " + @damage_total.to_s + " to " + defe.names 
            @guide.text = "MISS " + @dc.to_s  + " " + defe.names
        end
        check_defender_stats(defe)
        defe.initiate = true if defe != @hero && defe.decision != "attack"
        puts defe.initiate.to_s + " retaliate?" unless defe.names == @hero.names
    end

    def retaliation defe, atk
        attack(defe,atk) if @guide.text != "TARGET IS DEAD" 
        @hero.target = nil
        defe.initiate = false
    end

    def roll_d6
        return rand(5) + 1
    end

    def spawn_loot target
        if @room_number == 0 && target.id == [:npc] && @hero.default_weapon == 0
            @loot << Weapon_Cards.new
            @loot[@loot_count].icon = 1
            @loot[@loot_count].x = target.x
            @loot[@loot_count].y = target.y
            @loot[@loot_count].names = "Dagger"
            @guide.text = "Walk on the loot to equip."
            @loot_count += 1
        end
        if target.id == [:object]
            @loot << Weapon_Cards.new 
            @loot[@loot_count].icon = target.loot
            @loot[@loot_count].x = target.x
            @loot[@loot_count].y = target.y
            @loot[@loot_count].names = get_name(target.loot)
            @guide.text = "Walk on the loot to equip."
            @guide.text += " This will replace your current weapon" if target.loot == 2 || target.loot == 1
            @loot_count += 1
        end
    end

    def light_token
        @characters[@size_w/2][@size_h/2 + 1] = @samples[:token] if @hero.x == @size_w/2 && @hero.y == @size_h/2
        @characters[@size_w/2][@size_h/2] = @samples[:token] unless @hero.x == @size_w/2 && @hero.y == @size_h/2
        @domain = true
        puts domain.to_s + " token"
    end

    def check_defender_stats(defe)
        @check = [ :melee, :ranged, :touch, :ranged_magic ]
        for a in (0..4)
            if defe.stats[@check[a]] <= 0
                @red += 1
                return @check[a] if @choice == "heal" && defe.stats[@check[a]] < defe.max_stats[@check[a]]
            end
            if @red == 4
                @guide.text = "TARGET IS DEAD" 
                $trigger = false
                if defe.names != @hero.names
                    spawn_loot(defe)
                    @hero.kills += 1
                    light_token() if @npc_count == 0 || (@npc_count == 1 && @room_number == 0)
                    @npc_deck_drawn.delete_at(defe.id_t)
                    @npc_count -= 1
                else
                    $game.state_of_game = :game_over
                end
            end
            return false if @red == 0 && @choice == "heal"
        end
        if @hero.health == -1
            $game.state_of_game = :game_over
        end
        @red = 0
    end

    def apply_damage defe
        @check = [ :melee, :ranged, :touch, :ranged_magic ]
        defe.red = 0
        for a in (0..4)
            if defe.stats[@check[a]] > 0 
                puts @guide.text = @check[a].to_s + " reduced for " + defe.names
                return @check[a]
            else
                defe.red += 1 
            end
        end
        apply_damage(defe) if defe.red < 4 || defe.race == :noone
        return false
    end

    def distance a, b
        if (@hero.x - a).abs + (@hero.y - b).abs > @hero.line_of_sight
            #puts "far"
            return false 
        else
            return true
        end
    end

    def distance_habitat a,b
        if (@hero.x - a).abs + (@hero.y - b).abs > 2
            puts "far"
            return false 
        else
            puts "good"
            return true
        end
    end

    def distance_melee a, b
        if (@hero.x - a).abs + (@hero.y - b).abs > 2
            #puts "far"
            return false 
        else
            return true
            puts "close enough"
        end
    end 

    def take_loot i 
        @hero.default_weapon = @loot[i-1].icon
        if @loot[i-1].icon == 1
            @hero.klass = :cleric
            @hero.klass_cleric()
        end
        if @loot[i-1].icon == 2
            @hero.klass = :wizard
            @hero.klass_wizard()
        end
        @hero.encumbrance = @hero.default_weapon
        @hero.default_weapon_stats = @loot[i-1].stats[@loot[i-1].icon]
        @loot_count -= 1
        @loot.delete_at(i)
        $game.music_theme = 1
    end

    def check_for_obstacles sides, verts
        if sides != 0
            #puts sides
            @good = 0
            for a in (1..@hero.dash_distance)
                @dif_x = (a*sides) + @hero.x
                if @dif_x > 1 && @characters[@dif_x][@hero.y] == @samples[:floors]
                    @good += 1
                    puts "clear"
                    puts @good
                else
                    puts @dif_x.to_s + " distance final check"
                    return false
                end 
            end
            return true if @good == @hero.dash_distance
        end
    end

    def input args
        if inputs.keyboard.key_down.e 
            $gtk.reset seed: rand(100000)
            $game = nil
            $time_now = 0
            $timer = 0
        end
        if inputs.keyboard.key_down.q
            if @loot_count > 0
                for i in (0..@loot_count-1)
                    @guide.text = "New Item Acquired! " + @loot[i].icon.keys.to_s if i > 0 && distance(@loot[i].x,@loot[i].y)
                    take_loot(i)
                    @hero.stealth_actions += 1 if @hero.stealth_roll != -1
                end
            end
        end
        #puts $timer.elapsed?
        if @room[@hero.x][@hero.y] == @tiles[:lava] && $timer.elapsed? && @choice != "execute jump"
            puts "ouch" + @hero.red.to_s + " number of 0 stats"
            @hero.stats[apply_damage(@hero)] -= 1 and @hero.health -= 1 if @hero.red < 10
            if @hero.race == :noone || @hero.health == -1
                @guide.text = "You have died"
                $game.state_of_game = :game_over
            end
        end
        if inputs.keyboard.key_down.raw_key
            @guide.text = ""
            if @guide.chapter == 0 && @guide.page == 1 && object_count < 2
                spawn_objects()
            end
            @choice = "nothing" if @choice == "looked"
            @hero.target = :noone
            #puts @characters[@hero.x][@hero.y]
            #@trigger = true
        end
        if inputs.keyboard.key_down.one
            if @npc_count <= 1 && @hero.race != :noone && @room_number == 0
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

        if @choice == "execute jump"
            if $timer.elapsed?
                @characters[@hero.x][@hero.y] = @samples[:floors]
                @hero.x += (@hero.jump_to[0] - @hero.x).clamp(-1,1)
                @hero.y += (@hero.jump_to[1] - @hero.y).clamp(-1,1)
                update()
            end
            if @hero.x == @hero.jump_to[0] && @hero.y == @hero.jump_to[1]
                @choice = "nothing"
                $game.time_redux = 1
                @hero.skill_use[:jump] += 1
            end
        end
        
        if @choice == "dash"
            @sides ||= 0
            @sides = 1 if inputs.keyboard.key_down.right
            @sides = -1 if inputs.keyboard.key_down.left
            @verts = inputs.keyboard.key_down.down - inputs.keyboard.key_down.up
            if @sides != 0 && check_for_obstacles(@sides,@verts)
                @guide.text = "Way is clear"
                
                @choice = "execute dash"
                @hero.dash_dir_x = @sides
                $game.time_redux = 2
                @sides = 0
            end
            @sides = 0
        end

        if @choice == "execute dash"
            if $timer.elapsed?
                @characters[@hero.x][@hero.y] = @samples[:floors]
                @hero.x += @hero.dash_dir_x
                @hero.dash_used += 1
                update()
            end
            if @hero.dash_used == @hero.dash_distance
                @choice = "nothing"
                @hero.dash_used = 0
                @hero.skill_use[:dash] += 1
                @hero.stealth_actions += 1 if @hero.stealth_roll != -1
            end
        end


        if @choice != "execute jump" && @choice != "execute dash" && @choice != "dash"
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
                    @hero.init_elf()
                end
                if @characters[@hero.x][@hero.y - 1] == @samples[:dwarf_statue]
                    erase_statues()
                    @guide.chapter = 2
                    @guide.page = 0
                    @guide.text = @guide.book[@guide.chapter][@guide.page]
                    @hero.race = :dwarf
                    @hero.init_dwarf()
                end
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
        if @characters[@elf_statue.x][@elf_statue.y] != @samples[:floors]
            @elf_statue.x += 1
            @elf_statue.y += 1
        end
        if @characters[@dwarf_statue.x][@dwarf_statue.y] != @samples[:floors]
            @elf_statue.x += 1
            @elf_statue.y += 1
        end
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
                @npc_deck_drawn[@npc_count].id_t = @npc_count
                @coords = gen_coords()
                puts @coords
                @npc_deck_drawn[@npc_count].x = @coords[0]
                @npc_deck_drawn[@npc_count].y = @coords[1]  
                @characters[@npc_deck_drawn[@npc_count].x][@npc_deck_drawn[@npc_count].y] = @npc_deck_drawn[@npc_count].races[@npc_deck_drawn[@npc_count].race]
                #puts (@npc_deck_drawn[@npc_count].y - @pos_room_y).to_s + "y"
                #puts @npc_deck_drawn[@npc_count].names
                @guide.text = "NPC has been detected!1.0"
                @npc_deck_drawn[@npc_count].set_locations(0)
                @npc_count += 1
    end

    def update
        @characters[@hero.x][@hero.y] = @hero.races[@hero.race]
        @hero.stealth_actions += 1 if @hero.stealth_roll != -1 && @choice != "execute jump" && @choice != "execute dash"
        @guide.text = "STEALTH ACTIONS REMAINING: " + @hero.stealth_actions.to_s if @hero.stealth_roll != -1 && @choice != "execute jump" && @choice != "execute dash"
    end

    def update_npc npc
        @characters[npc.x][npc.y] = npc.races[npc.race] if npc.names != "GUIDE"
    end
end


class DM
    attr_gtk
    attr :state_of_menu_left, :state_of_menu_top, :rooms, :world_size_w, :world_size_h, :current_room, :music_list, :music_current, :volume, :music_theme, :state_of_game
    attr :time_redux, :picked_s

    def initialize
        @picked_s = false
        @state_of_menu_left = [:default]
        @state_of_menu_top = [:default]
        @rooms = []
        @rooms << Room.new
        @current_room = 0
        @rooms[@current_room].room_number = 0
        puts @rooms[@current_room].hero
        @music_list = [["knights_of_kalvgv_main_theme.ogg","knights_of_kalvgv_main_theme_variant_2.ogg","knights_of_kalvgv_main_theme_variant_3.ogg"],["knights_of_kalvgv_slight_relief.ogg","knights_of_kalvgv_slight_relief.ogg"]]
        @music_theme = 0
        @music_current = @music_list[@music_theme].sample
        @state_of_game = :playing
        @time_redux = 1
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

    def play_punch args
        args.audio[:punch] = {
            input: "sounds/sfx_punch.ogg",  # Filename
            x: 0.0, y: 0.0, z: 0.0,   # Relative position to the listener, x, y, z from -1.0 to 1.0
            gain: 1.0,                # Volume (0.0 to 1.0)
            pitch: 1.0,               # Pitch of the sound (1.0 = original pitch)
            paused: false,            # Set to true to pause the sound at the current playback position
            looping: false,           # Set to true to loop the sound/music until you stop it
        }
    end

    def play_punch args
        args.audio[:melee] = {
            input: "sounds/sfx_melee_sharp.ogg",  # Filename
            x: 0.0, y: 0.0, z: 0.0,   # Relative position to the listener, x, y, z from -1.0 to 1.0
            gain: 1.0,                # Volume (0.0 to 1.0)
            pitch: 1.0,               # Pitch of the sound (1.0 = original pitch)
            paused: false,            # Set to true to pause the sound at the current playback position
            looping: false,           # Set to true to loop the sound/music until you stop it
        }
    end

    def play_ranged args 
        args.audio[:ranged] = {
            input: "sounds/sfx_ranged.ogg",  # Filename
            x: 0.0, y: 0.0, z: 0.0,   # Relative position to the listener, x, y, z from -1.0 to 1.0
            gain: 1.0,                # Volume (0.0 to 1.0)
            pitch: 1.0,               # Pitch of the sound (1.0 = original pitch)
            paused: false,            # Set to true to pause the sound at the current playback position
            looping: false,           # Set to true to loop the sound/music until you stop it
        }
    end

    def play_lock_open args 
        args.audio[:rdoors] = {
            input: "sounds/sfx_door_open.ogg",  # Filename
            x: 0.0, y: 0.0, z: 0.0,   # Relative position to the listener, x, y, z from -1.0 to 1.0
            gain: 1.0,                # Volume (0.0 to 1.0)
            pitch: 1.0,               # Pitch of the sound (1.0 = original pitch)
            paused: false,            # Set to true to pause the sound at the current playback position
            looping: false,           # Set to true to loop the sound/music until you stop it
        }
    end

    def check_healing_near
        if @rooms[@current_room].habit_count > 0 && $timer.elapsed?
            for a in (0..@rooms[@current_room].habit_count - 1)
                #puts a, @rooms[@current_room].habitations[a].x
                if @rooms[@current_room].distance_habitat(@rooms[@current_room].habitations[a].x,@rooms[@current_room].habitations[a].y)
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
        elsif target.stats[:touch] < target.max_stats[:touch]
            target.stats[:touch] += 1
            target.heatlh += 1
            return puts "healed touch"
        elsif target.stats[:ranged_magic] < target.max_stats[:ranged_magic]
            target.stats[:ranged_magic] += 1
            target.health += 1
            return puts "healed ranged magic"
        end
        puts "full health"
    end
    
    def ui_select_jump
        {
            x: inputs.mouse.x-16.round() % 32,
            y: inputs.mouse.y-16.round() % 32,
            w: 32,
            h: 32,
            path: 'sprites/sprites.png',
            tile_x: 16*14,
            tile_y: 0,
            tile_w: 16,
            tile_h: 16
        }
    end

    def ui_tunnel_card card, count
        {
            x: 450 + (count * 100),
            y: 575,
            w: 75,
            h: 125,
            path: 'sprites/tunnel_deck.png',
            tile_x: card.deck[card.image] * 50,
            tile_y: 0,
            tile_w: 50,
            tile_h: 100
        }
    end

    def tick args
        $timer ||= 0
        check_healing_near() if @rooms[@current_room].habit_count > 0
        @rooms[@current_room].input(args)
        $timer = state.tick_count + (60 / @time_redux) if $timer < state.tick_count 
        if @rooms[@current_room].hero.line_of_sight == 3 && @rooms[@current_room].hero.race == :elf || @rooms[@current_room].hero.race == :dwarf
            @rooms[@current_room].hero.line_of_sight = 5
        end
        for i in (0...@rooms[@current_room].npc_count)
            #puts $time_now
            #@rooms[@current_room].npc_count -= 1; exit if @rooms[@current_room].npc_deck_drawn[i] == nil
            if  @rooms[@current_room].npc_deck_drawn[i] != nil && @rooms[@current_room].npc_count > 0 && @rooms[@current_room].npc_deck_drawn[i].names != "guide" && @rooms[@current_room].npc_deck_drawn[i].decision_timer < state.tick_count && @rooms[@current_room].npc_deck_drawn[i].names != "guide"
                @rooms[@current_room].ai(@rooms[@current_room].npc_deck_drawn[i])
                @rooms[@current_room].npc_deck_drawn[i].decision_timer = state.tick_count + 45
                if @rooms[@current_room].npc_deck_drawn[i].initiate 
                    play_ranged(args)
                end
                #puts @rooms[@current_room].npc_deck_drawn[i].decision_timer.to_s + " count to"
            end
            if @rooms[@current_room].npc_deck_drawn[i].initiate == true && @rooms[@current_room].npc_deck_drawn[i].names != "guide"
                @rooms[@current_room].timer(@rooms[@current_room].npc_deck_drawn[i].decision_timer , @rooms[@current_room].npc_deck_drawn[i])
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
            elsif @state_of_menu_left == [:skills] || @state_of_menu_left == [:spells] || @state_of_menu_left == [:stats] || state_of_menu_left == [:magic_skills]
                outputs.sprites << @rooms[@current_room].ui_back()
            end
        if @state_of_menu_left == [:skills]
            outputs.sprites << @rooms[@current_room].ui_button_int()
            outputs.sprites << @rooms[@current_room].ui_button_lock()
            outputs.sprites << @rooms[@current_room].ui_button_jump()
            outputs.sprites << @rooms[@current_room].ui_button_dash()
            outputs.sprites << @rooms[@current_room].ui_button_magic()
        end
        if @state_of_menu_left == [:magic_skills]
            outputs.sprites << @rooms[@current_room].ui_button_stealth()
            outputs.sprites << @rooms[@current_room].ui_button_heal()
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
        outputs.labels << [160,600, @rooms[@current_room].hero.race]#s[@rooms[@current_room].hero.race]]
        outputs.labels << [160,620, @rooms[@current_room].hero.klass]
        outputs.sprites << @rooms[@current_room].ui_top_bg()
        outputs.sprites << @rooms[@current_room].ui_weapon_cards()
        outputs.sprites << [10,10, 500, 70, "sprites/music_info.png"]
        outputs.labels << [20,70,@music_current.to_s]
        outputs.labels << [20,50,"by Shandor Jackson"]
        #outputs.labels << [100,200,@room]
        outputs.labels << [350, 555, @rooms[@current_room].guide.text]
        @rooms[@current_room].clicks()
        @rooms[@current_room].update() if inputs.keyboard.key_down.raw_key
        outputs.sprites << ui_select_jump() if @rooms[@current_room].choice == "jump"
        if @rooms[@current_room] != nil
            count = 0
            @rooms[@current_room].tunnel_cards.each do
                |c| 
                outputs.sprites << ui_tunnel_card(c, count)
                count += 1
            end
        end
        if @rooms[@current_room].choice == "attacked"
            if @rooms[@current_room].hero.default_weapon == 0
                play_punch(args)
            end
            if @rooms[@current_room].hero.default_weapon == 1
                play_melee(args)
            end
            if @rooms[@current_room].hero.default_weapon == 2
                play_ranged(args)
            end
            @rooms[@current_room].choice = "nothing"
        end
        if @picked_s == true
            play_lock_open(args)
            @picked_s = false
        end
    end

end

def tick args
    $game ||= DM.new
    if $game != nil && $game.state_of_game != :game_over
        $game.args = args and $game.rooms[$game.current_room].args = args and $game.args.state = args.state and $game.tick(args)
        $game.music_current = $game.music_list[$game.music_theme].sample and $game.play_music(args) if $game.args.audio[:my_audio] == nil
        $game.args.audio = args.audio #and puts args.audio
    else
        args.outputs.labels << [1280/2, 700/2, "Game OVER!"]
    end
end
