desc "Finds where Picky still needs input from you."
task :"to#{}do" do
  if system "grep -e 'TODO.*' -n --color=always -R *"
    puts "Picky needs a bit of input from you there. Thanks."
  else
    puts "Picky seems to be fine (no TODOs found)."
  end
end