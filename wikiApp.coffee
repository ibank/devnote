wiki = require './lib/wiki'

exports.getPages = (req, res) ->
    switch req.query.action
        when 'search' then search req, res
        else list req, res

# get wikipage list
list = (req, res) ->
    wiki.getPages (err, pages) ->
        if err
            error404 err, req, res
        else
            res.render 'pages',
                title: 'Pages',
                content: pages

exports.getPage = (req, res) ->
    name = req.params.name
    switch req.query.action
        when 'diff' then diff name, req, res
        when 'history' then history name, req, res
        when 'edit' then edit name, req, res
        else view name, req, res

view = (name, req, res) ->
    wiki.getPage name, (err, content) ->
        if err
            error404 err, req, res
        else
            res.render 'page',
                title: name,
                content: wiki.render content,
                
exports.getNew = (req, res) ->
    res.render 'new', title: 'New Page', pageName: '____new_' + new Date().getTime(), filelist: []
        
exports.postNew = (req, res) ->
    name = req.body.name
    wiki.writePage name, req.body.body, (err) ->
        res.redirect '/wikis/note/pages/' + name

exports.postDelete = (req, res) ->
    wiki.deletePage req.params.name, (err) ->
        res.render 'deleted',
            title: req.body.name,
            message: req.params.name,
            content: 'Page deleted',

exports.postRollback = (req, res) ->
    name = req.params.name
    wiki.rollback name, req.body.id, (err) ->
        wiki.getHistory name, (err, commits) ->
            if err
                error404 err, req, res
            else
                res.contentType 'json'
                res.send {commits: commits, name: name, ids: commits.ids}
                