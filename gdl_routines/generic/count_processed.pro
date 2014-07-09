PRO count_processed,EXIT_STATUS,cnt

; Start searching in character position 0.
  I = 0
; Number of occurrences found.
  cnt = 0


  nel = n_elements(EXIT_STATUS)

  FOR nel_i = 0,(nel-1) DO BEGIN
                                ; Search for an occurrence.
     WHILE (I NE -1) DO BEGIN
        I = STRPOS(EXIT_STATUS(nel_i), 'Processed', I)
        IF (I NE -1) THEN BEGIN
                                ; Update counter.
           cnt = cnt + 1
           I = I + 1
        ENDIF
     ENDWHILE

  ENDFOR

; Print the result.
  PRINT, cnt

end
