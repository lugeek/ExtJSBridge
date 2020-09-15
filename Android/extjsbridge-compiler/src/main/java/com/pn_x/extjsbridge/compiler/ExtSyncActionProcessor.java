package com.pn_x.extjsbridge.compiler;

import com.google.auto.service.AutoService;
import com.pn_x.extjsbridge.annotations.ExtActionVerify;
import com.pn_x.extjsbridge.annotations.ExtSyncAction;

import java.util.List;
import java.util.Set;

import javax.annotation.processing.Processor;
import javax.annotation.processing.RoundEnvironment;
import javax.annotation.processing.SupportedAnnotationTypes;
import javax.annotation.processing.SupportedSourceVersion;
import javax.lang.model.SourceVersion;
import javax.lang.model.element.Element;
import javax.lang.model.element.ElementKind;
import javax.lang.model.element.ExecutableElement;
import javax.lang.model.element.TypeElement;
import javax.lang.model.element.VariableElement;
import javax.lang.model.type.TypeMirror;
import javax.lang.model.type.TypeVariable;

@AutoService(Processor.class)
@SupportedAnnotationTypes({"com.pn_x.extjsbridge.annotations.ExtSyncAction"})
@SupportedSourceVersion(SourceVersion.RELEASE_8)
public class ExtSyncActionProcessor extends BaseProcessor {
    @Override
    public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv) {
        if (annotations != null && !annotations.isEmpty()) {
            Set<? extends Element> elements = roundEnv.getElementsAnnotatedWith(ExtSyncAction.class);
            try {
                info("Process ExtSyncAction start ...");
                this.parseSyncAction(elements);
            } catch (Exception e) {
                error(e.getMessage());
            }
            return true;
        }
        return false;
    }

    private void parseSyncAction(Set<? extends Element> elements) {
        if (elements == null || elements.isEmpty()) return;
        for (Element element : elements) {
            if (!(element instanceof ExecutableElement) || element.getKind() != ElementKind.METHOD) {
                error(element.asType().toString() + " @ExtSyncAction only works for method");
            }

            ExecutableElement executableElement = (ExecutableElement) element;
            TypeElement enclosingElement = (TypeElement) element.getEnclosingElement();

            String methodName = executableElement.getSimpleName().toString();
            ExtSyncAction syncAction = element.getAnnotation(ExtSyncAction.class);
            String action = syncAction.value();

            if (action == null || action.length() <= 0) {
                error("ExtSyncAction is empty for method: " + enclosingElement.toString());
            }

            ExtActionVerify verify = ExtSyncAction.class.getAnnotation(ExtActionVerify.class);
            if (verify != null) {
                String[] targetParameters = verify.parameters();
                String targetReturnType = verify.returnType();
                List<? extends VariableElement> nowParameters = executableElement.getParameters();
                TypeMirror nowReturnType = executableElement.getReturnType();
                if (nowReturnType instanceof TypeVariable) {
                    TypeVariable typeVariable = (TypeVariable) nowReturnType;
                    nowReturnType = typeVariable.getUpperBound();
                }
//                if (targetParameters.length != nowParameters.size()) {
//                    error(enclosingElement.toString() + "#" + executableElement.toString() + " sync parameters should be " + Arrays.toString(targetParameters).replaceAll("\\[", "(").replaceAll("]", ")"));
//                }
//                if (nowParameters.size() > 2) {
//                    error(enclosingElement.toString() + "#" + executableElement.toString() + " sync count of parameters should not exceed 2");
//                }
//                if (nowParameters.size() == 2) {
//                    for (int i = 0; i < targetParameters.length; i++) {
//                        String targetParameter = targetParameters[i];
//                        if (targetParameter.equals("java.lang.Object")) {
//                            continue;
//                        }
//                        String nowParameter = nowParameters.get(i).asType().toString();
//                        if (!targetParameter.equals(nowParameter)) {
//                            error(enclosingElement.toString() + "#" + executableElement.toString() + " parameters should be " + Arrays.toString(targetParameters).replaceAll("\\[", "(").replaceAll("]", ")"));
//                        }
//                    }
//                }
                if (!targetReturnType.equals("java.lang.Object") && !targetReturnType.equals(nowReturnType.toString())) {
                    error(enclosingElement.toString() + "#" + executableElement.toString() + " return type should be " + targetReturnType);
                }
            }

        }
    }
}
