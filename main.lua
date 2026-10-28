-- Part 1: create the window and two keyboard-controlled paddles.
local player1, player2
local windowWidth, windowHeight = 800, 600

-- Runs once when the game starts.
function love.load()
    love.window.setMode(windowWidth, windowHeight)
    love.window.setTitle("Pong - LÖVE2D")
    love.graphics.setBackgroundColor(0.06, 0.07, 0.10)
    player1 = { x = 40, y = 250, width = 16, height = 100, speed = 360 }
    player2 = { x = 744, y = 250, width = 16, height = 100, speed = 360 }
end

local function movePaddle(paddle, up, down, dt)
    if love.keyboard.isDown(up) then
        paddle.y = paddle.y - paddle.speed * dt
    end
    if love.keyboard.isDown(down) then
        paddle.y = paddle.y + paddle.speed * dt
    end
    paddle.y = math.max(0, math.min(windowHeight - paddle.height, paddle.y))
end

-- Runs each frame; dt is elapsed time in seconds.
function love.update(dt)
    movePaddle(player1, "w", "s", dt)
    movePaddle(player2, "up", "down", dt)
end

-- Runs each frame to display the current positions.
function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", player1.x, player1.y, player1.width, player1.height)
    love.graphics.rectangle("fill", player2.x, player2.y, player2.width, player2.height)
end
