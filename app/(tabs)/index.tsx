import React, { useState, useEffect } from 'react';
import {
    StyleSheet,
    View,
    Text,
    TextInput,
    Button,
    FlatList,
    TouchableOpacity,
    Alert,
    Platform,
    NativeModules,
} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';


// iOS 위젯과의 통신을 위한 네이티브 모듈 (나중에 Xcode 설정 필요)
const { SharedDataManager } = NativeModules;

const TODO_STORAGE_KEY = 'todoListKey`';

export default function App() {
    const [todos, setTodos] = useState([]);
    const [newTodo, setNewTodo] = useState<string>('');

    const updateWidget = (currentTodos:any) => {

        if (Platform.OS === 'ios' && SharedDataManager ) {
            try {
                const widgetData = currentTodos.slice(0, 5).map((todo:any) => todo.text);
                SharedDataManager.saveTodosToSharedDefaults(JSON.stringify(widgetData))
                    .then(() => {
                        console.log('Todos sent to widget successfully!', widgetData);
                    })
                    .catch((error:any) => {
                        console.error('Failed to send todos to widget:', error.message);
                    });
            } catch (error) {
                console.error("Error preparing data for widget:", error);
            }
        }
    };

    const loadTodos = async () => {
        try {
            console.log("?FQWfqw")
            const storedTodos = await AsyncStorage.getItem(TODO_STORAGE_KEY);
            if (storedTodos) {
                setTodos(JSON.parse(storedTodos));
                // 위젯에 데이터 업데이트 요청 (앱 시작 시)
                updateWidget(JSON.parse(storedTodos));
            }
        } catch (e) {
            console.error('Failed to load todos.', e);
        }
    };

    const saveTodos = async (currentTodos:any) => {
            await AsyncStorage.setItem(TODO_STORAGE_KEY, JSON.stringify(currentTodos));
            updateWidget(currentTodos);
    };

    const addTodo = () => {
        if (newTodo.trim().length > 0) {
            const updatedTodos = [...todos, { id: Date.now().toString(), text: newTodo.trim() }] as any;
            setTodos(updatedTodos);
            saveTodos(updatedTodos);
            setNewTodo('');
        } else {
            Alert.alert('오류', '할 일을 입력해주세요!');
        }
    };

    const deleteTodo = (id:any) => {
        Alert.alert(
            '할 일 삭제',
            '정말로 이 할 일을 삭제하시겠습니까?',
            [
                {
                    text: '취소',
                    style: 'cancel',
                },
                {
                    text: '삭제',
                    onPress: () => {
                        const updatedTodos = todos.filter((todo:any) => todo.id !== id);
                        setTodos(updatedTodos);
                        saveTodos(updatedTodos);
                    },
                },
            ],
            { cancelable: true }
        );
    };

    useEffect(() => {
        loadTodos();
    }, []);

    const renderItem = ({ item }: {item :any}) => (
        <View style={styles.todoItem}>
            <View><Text>id : {item.id}</Text></View>
            <View><Text style={styles.todoText}>text : {item.text}</Text></View>

            <TouchableOpacity onPress={() => deleteTodo(item.id)} style={styles.deleteButton}>
                <Text style={styles.deleteButtonText}>삭제</Text>
            </TouchableOpacity>
        </View>
    );

    return (
        <View style={styles.container}>
            <Text style={styles.title}>나의 할 일 목록</Text>
            <View style={styles.inputContainer}>
                <TextInput
                    style={styles.input}
                    placeholder="새로운 할 일 추가"
                    value={newTodo}
                    onChangeText={setNewTodo}
                />
                <Button title="추가" onPress={addTodo} />
            </View>
            <FlatList
                data={todos}
                renderItem={renderItem}
                keyExtractor={(item) => item.id}
                ListEmptyComponent={<Text style={styles.emptyText}>할 일이 없습니다. 추가해보세요!</Text>}
            />
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        paddingTop: 50,
        paddingHorizontal: 20,
        backgroundColor: '#f5f5f5',
    },
    title: {
        fontSize: 28,
        fontWeight: 'bold',
        marginBottom: 20,
        textAlign: 'center',
        color: '#333',
    },
    inputContainer: {
        flexDirection: 'row',
        marginBottom: 20,
        alignItems: 'center',
    },
    input: {
        flex: 1,
        height: 45,
        borderColor: '#ddd',
        borderWidth: 1,
        borderRadius: 8,
        paddingHorizontal: 12,
        marginRight: 10,
        backgroundColor: '#fff',
    },
    todoItem: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        backgroundColor: '#fff',
        padding: 15,
        borderRadius: 8,
        marginBottom: 10,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.1,
        shadowRadius: 2,
        elevation: 2,
    },
    todoText: {
        fontSize: 18,
        color: '#555',
        flex: 1, // 텍스트가 길어질 경우를 대비
    },
    deleteButton: {
        backgroundColor: '#ff6b6b',
        paddingVertical: 8,
        paddingHorizontal: 12,
        borderRadius: 5,
    },
    deleteButtonText: {
        color: '#fff',
        fontWeight: 'bold',
    },
    emptyText: {
        textAlign: 'center',
        marginTop: 50,
        fontSize: 16,
        color: '#888',
    },
});
