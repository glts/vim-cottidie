cottidie.vim
============

This Vim plugin brings friendly, syntax-highlighted Vim tips to your
messages area. At 78 characters these have enough substance to inspire
but not enough to distract. Try it out:

    :CottidieTip

The location of the tips file is configurable, so this plugin may also
serve you as a "daily tip" engine which draws from your own notes. (Not
actually daily though, it doesn't include any timing mechanism.)

The target audience is intermediate level. Contributions are welcome!

Demo
----

This is what a tip looks like on my Vim when hooked to the VimEnter
event (and `'cmdheight'` is set to 2).

![tip](https://raw.github.com/glts/vim-cottidie/gh-pages/images/tip-udot.png)

Installation
------------

Move the files into their respective directories inside your `~/.vim`
directory (or your `$HOME\vimfiles` directory if you're on Windows).

With pathogen.vim the installation is as simple as:

    cd ~/.vim/bundle
    git clone https://github.com/glts/vim-cottidie.git cottidie

FQA
---

> The tips appear truncated/incomplete/otherwise mangled in the messages
> area.

I'm aware of the issues with `:echo`. Hopefully I can find the time to
look into this, but until then refer to [this
report](https://groups.google.com/d/msg/vim_dev/o5VRJl9ZbsA/-o-JQRHcvhcJ)
on the vim\_dev mailing list.

> Vim errors out with E484 when it tries to load my remote tips file.

Try adding "nested" to the VimEnter autocommand so that it reads

    autocmd VimEnter * nested CottidieTip
