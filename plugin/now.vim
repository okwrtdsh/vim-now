if exists("g:loaded_now")
  finish
endif
let g:loaded_now = 1

let s:save_cpo = &cpo
set cpo&vim

command! RunNow call now#run()
command! KillNow call now#kill()
command! Now call now#toggle()

let &cpo = s:save_cpo
unlet s:save_cpo
