def readCPU(option, output_path, fileName):
    command = "sysbench --test=cpu --cpu-max-prime=" + str(option) + " run"
    path = output_path + "" + fileName + ".txt"
    file = open(path, 'a')
    subprocess.call(command, shell=True, stdout=file)
    print(command)
    file.close()

def readIO(bs, count, output_path, fileName):
    command = "dd if=/dev/zero of=sb-io-test bs=" + str(bs) + " count="
     + str(count)+" run"
    path = output_path + "/" + fileName + ".txt"
    file = open(path, 'a')
    subprocess.call(command, shell=True, stderr=file)
    file.close()
