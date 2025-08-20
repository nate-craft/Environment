local colors = {
    reset = "\27[0m",
    title = "\27[1;36m",  -- Cyan
    artist = "\27[1;36m",  -- Cyan
    genre = "\27[1;36m",  -- Cyan
    track = "\27[1;36m",  -- Cyan
    progress = "\27[1;33m" -- Yellow
}

function format_time(seconds)
    local m = math.floor(seconds / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02d:%02d", m, s)
end

function escape_filename(filename)
    return string.gsub(filename, "'", "'\\''") 
end

function has_cover_art(filename)
    filename = escape_filename(filename) 
    local temp_file = "/tmp/mpv_cover.png"
    os.execute("rm -f " .. temp_file)

    os.execute(string.format("ffmpeg -hide_banner -loglevel error -i '%s' -map 0:v -frames:v 1 -vf 'scale=150:-1' -f image2 '%s' 2>/dev/null", filename, temp_file))

    local file = io.open(temp_file, "r")
    if file then
        file:close()
        return true
    else
        return false
    end
end

function show_metadata()
    os.execute("clear")
    io.write("\r" .. string.rep(" ", 50) .. "\r")

    local filename = mp.get_property("path")
    local title = mp.get_property("media-title", "Unknown Title")
    local artist = mp.get_property("metadata/by-key/Artist", "Unknown Artist")
    local genre = mp.get_property("metadata/by-key/Genre", "Unknown Genre")
    
    if has_cover_art(filename) then
        os.execute(string.format("img2sixel '%s' 2>/dev/null", "/tmp/mpv_cover.png"))
    else
        os.execute(string.format("ffmpeg -hide_banner -loglevel error -i '%s/.config/mpv/default-cover.png' -vf 'scale=150:-1' -f image2pipe - | img2sixel 2>/dev/null", os.getenv("HOME")))
    end

    io.write("\r" .. colors.title .. "Title: " .. title .. colors.reset)
    io.write("\n" .. colors.artist .. "Artist: " .. artist .. colors.reset)
    io.write("\n" .. colors.genre .. "Genre: " .. genre .. colors.reset)
    show_track_progress()
    io.write("\n\n")

    show_progress()
end

function show_track_progress()
    local playlist_size = (tonumber(mp.get_property("playlist-count")) or 1)
    local current_index = (tonumber(mp.get_property("playlist-pos")) or 0) + 1
    if playlist_size > 1 then
        io.write(string.format("\n\r%sTrack: (%d/%d)%s", colors.track, current_index, playlist_size, colors.reset))
        io.flush()
    end
end

function show_progress()
    local elapsed = mp.get_property_number("time-pos", 0)
    local remaining = mp.get_property_number("time-remaining", 0)
    local total = elapsed + remaining

    io.write("\r" .. colors.progress .. "Progress: " .. format_time(elapsed) .. " / " .. format_time(total) .. colors.reset)
    io.flush()
end

mp.register_event("file-loaded", show_metadata)
mp.add_periodic_timer(1, show_progress)
