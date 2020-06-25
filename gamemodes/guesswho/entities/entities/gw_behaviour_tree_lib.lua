AddCSLuaFile()

local Status = {}
Status.Success = 1
Status.Failure = 2

-- Action: execute provided tick function.
-- The tick function should return Status.Success or Status.Failure
local ActionMeta = {
    Tick = function(self)
        return self.tickFunc()
    end
}
ActionMeta.__index = ActionMeta


local function CreateAction(tickFunc)
    local instance = {}
    instance.tickFunc = tickFunc

    setmetatable(instance, ActionMeta)

    return instance
end

-- Condtion returns Status.Success if the provided condition func returns true
-- returns Status.Failure otherwise
-- This is basically an alias for:
-- CreateAction(function() return cond and Status.Success or Status.Failure end)
local ConditionMeta = {
    Tick = function(self)
        if self.conditionFunc() then
            return Status.Success
        else
            return Status.Failure
        end
    end
}
ConditionMeta.__index = ConditionMeta

local function CreateCondition(conditionFunc)
    local instance = {}
    instance.conditionFunc = conditionFunc

    setmetatable(instance, ConditionMeta)

    return instance
end

-- Executes all children until one children returns success.
-- If all children have been iterated without one succeeding failure will be returned
local SelectorMeta = {
    AddChild = function(self, child)
        table.insert(self.children, child)
    end,
    Tick = function(self)
        while true do
            local currentChild = self.children[self.currentChildID]
            local status = currentChild:Tick()
            if status == Status.Success then
                self.currentChildID = 1
                return status
            elseif status == Status.Running then
                return status
            end

            self.currentChildID = self.currentChildID + 1
            if self.currentChildID == (#self.children + 1) then
                self.currentChildID = 1
                return Status.Failure
            end
        end
    end
}
SelectorMeta.__index = SelectorMeta

local function CreateSelector()
    local instance = {}

    instance.currentChildID = 1

    instance.children = {}

    setmetatable(instance, SelectorMeta)

    return instance
end

-- Executes all children until a failure is encountered.
local SequenceMeta = {
    AddChild = function(self, child)
        table.insert(self.children, child)
    end,
    Tick = function(self)
        while true do
            local currentChild = self.children[self.currentChildID]
            local status = currentChild:Tick()
            if status == Status.Failure then
                self.currentChildID = 1
                return status
            elseif status == Status.Running then
                return status
            end
            self.currentChildID = self.currentChildID + 1
            if self.currentChildID == (#self.children + 1) then
                self.currentChildID = 1
                return Status.Success
            end
        end
    end
}
SequenceMeta.__index = SequenceMeta

local function CreateSequence()
    local instance = {}

    instance.currentChildID = 1

    instance.children = {}

    setmetatable(instance, SequenceMeta)

    return instance
end

-- Parallel ticks all children in "parallel"
-- Strictly speaking they will still executed  one after the other.
-- But unlike Sequence wont stop iteration on Status.Failure or Status.Success
-- unless requiredToFail and/or requiredToSucceed is provided.
local ParallelMeta = {
    AddChild = function(self, child)
        table.insert(self.children, child)
    end,
    Tick = function(self)
        local successCounter = 0
        local failCounter = 0
        for _, child in pairs(self.children) do
            local result = child:Tick()
            if result == Status.Failure then
                failCounter = failCounter + 1
                if failCounter == self.requiredToFail then
                    return Status.Failure
                end
            end
            if result == Status.Success then
                successCounter = successCounter + 1
                if failCounter == self.requiredToSucceed then
                    return Status.Success
                end
            end
        end
        if (self.requiredToFail == (-1)) and (failCounter == (#self.children)) then
            return Status.Failure
        end
        if (self.requiredToSucceed == (-1)) and (successCounter == (#self.children)) then
            return Status.Success
        end
        return Status.Running
    end
}
ParallelMeta.__index = ParallelMeta

local function CreateParallel(requiredToFail, requiredToSucceed)
    local instance = {}

    if requiredToFail == nil then
        requiredToFail = -1
    end
    instance.requiredToFail = requiredToFail

    if requiredToSucceed == nil then
        requiredToSucceed = -1
    end
    instance.requiredToSucceed = requiredToSucceed

    instance.children = {}

    setmetatable(instance, ParallelMeta)

    return instance
end

-- Tree that ticks its root node.
-- Use in combination with other nodes!
local TreeMeta = {
    SetRoot = function(self, newRoot)
        self.root = newRoot
    end,
    Tick = function(self)
        if self.root then
            return self.root:Tick()
        else
            print("WARNING! TICKING EMPTY BEHAVIOR TREE!")
            return Status.Failure
        end
    end
}
TreeMeta.__index = TreeMeta

local function CreateTree(root)
    local instance = {}

    instance.root = root

    setmetatable(instance, TreeMeta)

    return instance
end

-- Fluent API for creating a behavoir tree
local TreeBuilderMeta = {
    Action = function(self, func)
        assert(not self:ParentStackEmpty(), "Can\'t create this node without a parent (sequence/selector)")
        self:PeekParent():AddChild(CreateAction(func))
        return self
    end,
    Condition = function(self, func)
        assert(not self:ParentStackEmpty(), "Can\'t create this node without a parent (sequence/selector)")
        self:PeekParent():AddChild(CreateCondition(func))
        return self
    end,
    Sequence = function(self)
        self:PushParent(CreateSequence())
        return self
    end,
    Selector = function(self)
        self:PushParent(CreateSelector())
        return self
    end,
    -- Completes current composite
    Finish = function(self)
        self:PopParent()
        return self
    end,
    Build = function(self)
        return self.result
    end,
    PushParent = function(self, parent)
        if self:ParentStackEmpty() then
            self.result:SetRoot(parent)
        end
        self.parentStack[(#self.parentStack) + 1] = parent
    end,
    PopParent = function(self)
        local old = self:PeekParent()
        self.parentStack[((#self.parentStack) - 1) + 1] = nil
        return old
    end,
    PeekParent = function(self)
        return self.parentStack[((#self.parentStack) - 1) + 1]
    end,
    ParentStackEmpty = function(self)
        return (#self.parentStack) == 0
    end
}
TreeBuilderMeta.__index = TreeBuilderMeta

local function TreeBuilder()
    local instance = {}

    instance.parentStack = {}
    instance.result = CreateTree()

    setmetatable(instance, TreeBuilderMeta)

    return instance
end

return {
    Status = Status,
    CreateAction = CreateAction,
    CreateCondition = CreateCondition,
    CreateSelector = CreateSelector,
    CreateSequence = CreateSequence,
    CreateParallel = CreateParallel,
    CreateTree = CreateTree,
    TreeBuilder = TreeBuilder
}
