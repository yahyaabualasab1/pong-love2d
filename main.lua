-- Positions and sizes are pixels; speeds are pixels per second.
local game = { width = 800, height = 600 }
local startingDX, startingDY = 300, 180
local maximumBallSpeed = 850
local nextServe = 1

function game.resetBall(direction)
    game.ball = {
        x = (game.width - 14) / 2,
        y = (game.height - 14) / 2,
        width = 14, height = 14,
        dx = startingDX * direction, dy = startingDY
    }
end

function game.reset()
    game.player1 = { x = 40, y = 250, width = 16, height = 100, speed = 360, score = 0 }
    game.player2 = { x = 744, y = 250, width = 16, height = 100, speed = 360, score = 0 }
    nextServe = 1
    game.resetBall(nextServe)
end

-- AABB: all four comparisons must be true for two rectangles to overlap.
function game.checkCollision(a, b)
    return a.x < b.x + b.width
        and a.x + a.width > b.x
        and a.y < b.y + b.height
        and a.y + a.height > b.y
end

local function movePaddle(paddle, up, down, dt, isDown)
    if isDown(up) then
        paddle.y = paddle.y - paddle.speed * dt
    end
    if isDown(down) then
        paddle.y = paddle.y + paddle.speed * dt
    end
    paddle.y = math.max(0, math.min(game.height - paddle.height, paddle.y))
end

local function speedUp(ball)
    local speed = math.sqrt(ball.dx * ball.dx + ball.dy * ball.dy)
    local factor = math.min(1.05, maximumBallSpeed / speed)
    ball.dx = ball.dx * factor
    ball.dy = ball.dy * factor
end

local function step(dt, isDown)
    movePaddle(game.player1, "w", "s", dt, isDown)
    movePaddle(game.player2, "up", "down", dt, isDown)
    local ball = game.ball
    -- velocity (pixels/second) * dt (seconds) = distance (pixels).
    ball.x = ball.x + ball.dx * dt
    ball.y = ball.y + ball.dy * dt
    if ball.y < 0 then
        ball.y = 0
        ball.dy = math.abs(ball.dy)
    elseif ball.y + ball.height > game.height then
        ball.y = game.height - ball.height
        ball.dy = -math.abs(ball.dy)
    end
    if ball.dx < 0 and game.checkCollision(ball, game.player1) then
        -- Move outside the paddle to avoid repeated bounces inside it.
        ball.x = game.player1.x + game.player1.width
        ball.dx = -ball.dx
        speedUp(ball)
    elseif ball.dx > 0 and game.checkCollision(ball, game.player2) then
        ball.x = game.player2.x - ball.width
        ball.dx = -ball.dx
        speedUp(ball)
    end
    -- A missed ball awards one point to the opponent, then starts a new rally.
    if ball.x + ball.width < 0 or ball.x > game.width then
        if ball.x + ball.width < 0 then
            game.player2.score = game.player2.score + 1
        else
            game.player1.score = game.player1.score + 1
        end
        nextServe = -nextServe
        game.resetBall(nextServe)
    end
end

function game.update(dt, isDown)
    -- Small steps stop a fast ball skipping through a thin paddle.
    -- Use all elapsed time so a slow frame moves the correct distance.
    local steps = math.max(1, math.ceil(dt / (1 / 240)))
    for _ = 1, steps do
        step(dt / steps, isDown)
    end
end



local titleFont, labelFont

-- love.load runs once: prepare the window, fonts and starting positions.
function love.load()
    love.window.setMode(game.width, game.height)
    love.window.setTitle("Pong - LÖVE2D")
    love.graphics.setBackgroundColor(0.06, 0.07, 0.10)
    titleFont = love.graphics.newFont(26)
    labelFont = love.graphics.newFont(14)
    game.reset()
end

-- love.update runs each frame. dt is elapsed time in seconds.
function love.update(dt)
    game.update(dt, love.keyboard.isDown)
end

-- love.draw displays the current state; movement belongs in love.update.
function love.draw()
    love.graphics.setColor(0.18, 0.20, 0.25)
    for y = 0, game.height, 28 do
        love.graphics.rectangle("fill", game.width / 2 - 1, y, 2, 14)
    end
    love.graphics.setFont(titleFont)
    love.graphics.setColor(0.88, 0.91, 0.96)
    love.graphics.printf("P O N G", 0, 20, game.width, "center")
    love.graphics.setFont(labelFont)
    love.graphics.setColor(0.55, 0.61, 0.71)
    love.graphics.printf("PLAYER 1  /  W + S", 90, 28, 220, "center")
    love.graphics.printf("PLAYER 2  /  UP + DOWN", 490, 28, 220, "center")
    love.graphics.setFont(titleFont)
    love.graphics.setColor(0.35, 0.55, 0.95)
    love.graphics.printf(tostring(game.player1.score), 90, 52, 220, "center")
    love.graphics.setColor(0.85, 0.30, 0.35)
    love.graphics.printf(tostring(game.player2.score), 490, 52, 220, "center")
    love.graphics.setFont(labelFont)
    love.graphics.setColor(0.10, 0.25, 0.60) -- Dark blue: left paddle.
    love.graphics.rectangle("fill", game.player1.x, game.player1.y, game.player1.width, game.player1.height)
    love.graphics.setColor(0.65, 0.12, 0.16) -- Dark red: right paddle.
    love.graphics.rectangle("fill", game.player2.x, game.player2.y, game.player2.width, game.player2.height)
    love.graphics.setColor(0.94, 0.96, 1)
    local ball = game.ball
    love.graphics.rectangle("fill", ball.x, ball.y, ball.width, ball.height)
    love.graphics.setColor(0.55, 0.61, 0.71)
    love.graphics.printf("+5% BALL SPEED PER PADDLE HIT  /  R TO RESET", 0, 573, game.width, "center")
end

function love.keypressed(key)
    if key == "r" then
        game.reset()
    end
end
