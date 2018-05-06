let s:save_cpo = &cpo
set cpo&vim

if !exists("g:now_port")
  let g:now_port = 8765
endif

let s:cmd = expand('<sfile>:h:h:gs!\\!/!') . '/now/now'
let s:now_enabled = 0

function! s:handle(ch, msg)
  echo a:msg
endfunction

function! s:kill()
  if exists("s:ch")
    call ch_close(s:ch)
    unlet s:ch
    let s:now_enabled = 0
  endif
  if exists("s:job")
    call job_stop(s:job, "kill")
    unlet s:job
  endif
endfunction

function! s:init()
  call s:kill()
  let s:job = job_start(s:cmd . ' -p ' . g:now_port)
  sleep 50m
  let s:ch = ch_open(
        \ "127.0.0.1:" . g:now_port,
        \ {'mode': 'json', 'callback': function('s:handle')})
  let s:now_enabled = 1
endfunction

function! now#run()
  call s:init()
  call ch_sendexpr(s:ch, "run")
endfunction

function! now#kill()
  call s:kill()
endfunction

function! now#toggle()
  if s:now_enabled
    call now#kill()
  else
    call now#run()
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
